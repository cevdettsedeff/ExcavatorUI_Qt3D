#!/usr/bin/env python3
"""
CartoDB/OSM Tile Downloader for ExcavatorUI
Downloads map tiles for offline use

Usage:
    python download_tiles.py --provider cartodb --region turkey --zoom-min 13 --zoom-max 16
"""

import argparse
import os
import sys
import time
import math
import requests
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Tuple

# Predefined regions
REGIONS = {
    'turkey': {
        'name': 'Türkiye',
        'min_lat': 36.0,
        'max_lat': 42.1,
        'min_lon': 26.0,
        'max_lon': 45.0
    },
    'istanbul': {
        'name': 'İstanbul',
        'min_lat': 40.8,
        'max_lat': 41.2,
        'min_lon': 28.7,
        'max_lon': 29.3
    },
    'ankara': {
        'name': 'Ankara',
        'min_lat': 39.7,
        'max_lat': 40.1,
        'min_lon': 32.5,
        'max_lon': 33.1
    },
    'izmir': {
        'name': 'İzmir',
        'min_lat': 38.3,
        'max_lat': 38.6,
        'min_lon': 26.9,
        'max_lon': 27.3
    }
}

# Tile providers
PROVIDERS = {
    'osm': {
        'name': 'OpenStreetMap',
        'url': 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        'subdomains': ['a', 'b', 'c'],
        'user_agent': 'ExcavatorUI/1.0 (Offline Map Download)'
    },
    'cartodb': {
        'name': 'CartoDB Positron',
        'url': 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
        'subdomains': ['a', 'b', 'c', 'd'],
        'user_agent': 'ExcavatorUI/1.0 (Offline Map Download)'
    }
}


def lon_to_tile_x(lon: float, zoom: int) -> int:
    """Convert longitude to tile X coordinate"""
    return int(math.floor((lon + 180.0) / 360.0 * (1 << zoom)))


def lat_to_tile_y(lat: float, zoom: int) -> int:
    """Convert latitude to tile Y coordinate"""
    lat_rad = math.radians(lat)
    return int(math.floor((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * (1 << zoom)))


def get_tile_url(provider: str, z: int, x: int, y: int) -> str:
    """Generate tile URL for given coordinates"""
    provider_info = PROVIDERS[provider]
    subdomain = provider_info['subdomains'][(x + y) % len(provider_info['subdomains'])]
    return provider_info['url'].format(s=subdomain, z=z, x=x, y=y)


def download_tile(provider: str, z: int, x: int, y: int, output_dir: Path, retry: int = 3) -> Tuple[bool, str]:
    """Download a single tile"""
    tile_path = output_dir / str(z) / str(x) / f"{y}.png"

    # Skip if already exists
    if tile_path.exists():
        return True, f"Skip {z}/{x}/{y} (already exists)"

    # Create directory
    tile_path.parent.mkdir(parents=True, exist_ok=True)

    # Download
    url = get_tile_url(provider, z, x, y)
    headers = {'User-Agent': PROVIDERS[provider]['user_agent']}

    for attempt in range(retry):
        try:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()

            # Save tile
            with open(tile_path, 'wb') as f:
                f.write(response.content)

            return True, f"Downloaded {z}/{x}/{y}"

        except Exception as e:
            if attempt == retry - 1:
                return False, f"Failed {z}/{x}/{y}: {str(e)}"
            time.sleep(0.5 * (attempt + 1))  # Exponential backoff

    return False, f"Failed {z}/{x}/{y}: Max retries exceeded"


def estimate_tile_count(min_lat: float, max_lat: float, min_lon: float, max_lon: float,
                        zoom_min: int, zoom_max: int) -> int:
    """Estimate total number of tiles to download"""
    total = 0
    for z in range(zoom_min, zoom_max + 1):
        min_x = lon_to_tile_x(min_lon, z)
        max_x = lon_to_tile_x(max_lon, z)
        min_y = lat_to_tile_y(max_lat, z)  # Y is inverted
        max_y = lat_to_tile_y(min_lat, z)

        # Clamp to valid range
        max_tile = (1 << z) - 1
        min_x = max(0, min_x)
        max_x = min(max_tile, max_x)
        min_y = max(0, min_y)
        max_y = min(max_tile, max_y)

        count = (max_x - min_x + 1) * (max_y - min_y + 1)
        total += count

    return total


def download_region(provider: str, min_lat: float, max_lat: float, min_lon: float, max_lon: float,
                    zoom_min: int, zoom_max: int, output_dir: Path, workers: int = 2):
    """Download all tiles for a region"""

    print(f"\n{'='*60}")
    print(f"Downloading {PROVIDERS[provider]['name']} tiles")
    print(f"Region: {min_lat}°-{max_lat}°N, {min_lon}°-{max_lon}°E")
    print(f"Zoom levels: {zoom_min}-{zoom_max}")
    print(f"Output: {output_dir}")
    print(f"{'='*60}\n")

    # Estimate tile count
    total_tiles = estimate_tile_count(min_lat, max_lat, min_lon, max_lon, zoom_min, zoom_max)
    estimated_size_mb = total_tiles * 30 / 1024

    print(f"Estimated tiles: ~{total_tiles:,}")
    print(f"Estimated size: ~{estimated_size_mb:.1f} MB\n")

    # Confirm
    confirm = input(f"Continue with download? [y/N]: ")
    if confirm.lower() != 'y':
        print("Download cancelled.")
        return

    # Generate tile list
    tiles = []
    for z in range(zoom_min, zoom_max + 1):
        min_x = lon_to_tile_x(min_lon, z)
        max_x = lon_to_tile_x(max_lon, z)
        min_y = lat_to_tile_y(max_lat, z)  # Y is inverted
        max_y = lat_to_tile_y(min_lat, z)

        # Clamp to valid range
        max_tile = (1 << z) - 1
        min_x = max(0, min_x)
        max_x = min(max_tile, max_x)
        min_y = max(0, min_y)
        max_y = min(max_tile, max_y)

        for x in range(min_x, max_x + 1):
            for y in range(min_y, max_y + 1):
                tiles.append((z, x, y))

    print(f"\nDownloading {len(tiles):,} tiles with {workers} workers...\n")

    # Download tiles
    downloaded = 0
    failed = 0
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {executor.submit(download_tile, provider, z, x, y, output_dir): (z, x, y)
                   for z, x, y in tiles}

        for future in as_completed(futures):
            success, message = future.result()
            if success:
                downloaded += 1
            else:
                failed += 1
                print(f"❌ {message}")

            # Progress
            total_done = downloaded + failed
            if total_done % 100 == 0 or total_done == len(tiles):
                elapsed = time.time() - start_time
                speed = total_done / elapsed if elapsed > 0 else 0
                eta = (len(tiles) - total_done) / speed if speed > 0 else 0

                print(f"Progress: {total_done}/{len(tiles)} ({100*total_done/len(tiles):.1f}%) "
                      f"| Downloaded: {downloaded} | Failed: {failed} "
                      f"| Speed: {speed:.1f} tiles/s | ETA: {eta:.0f}s")

            # Rate limiting (respect server policies)
            time.sleep(0.1)  # 10 tiles/second max

    # Summary
    elapsed = time.time() - start_time
    print(f"\n{'='*60}")
    print(f"Download complete!")
    print(f"Total time: {elapsed:.1f}s")
    print(f"Downloaded: {downloaded:,} tiles")
    print(f"Failed: {failed:,} tiles")
    print(f"Average speed: {downloaded/elapsed:.1f} tiles/s")

    # Calculate actual size
    total_size = sum(f.stat().st_size for f in output_dir.rglob('*.png'))
    print(f"Total size: {total_size / 1024 / 1024:.1f} MB")
    print(f"{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(description='Download map tiles for offline use')

    # Provider
    parser.add_argument('--provider', choices=['osm', 'cartodb'], default='cartodb',
                        help='Tile provider (default: cartodb)')

    # Region (predefined or custom)
    parser.add_argument('--region', choices=list(REGIONS.keys()),
                        help='Predefined region to download')
    parser.add_argument('--lat-min', type=float, help='Minimum latitude')
    parser.add_argument('--lat-max', type=float, help='Maximum latitude')
    parser.add_argument('--lon-min', type=float, help='Minimum longitude')
    parser.add_argument('--lon-max', type=float, help='Maximum longitude')

    # Zoom range
    parser.add_argument('--zoom-min', type=int, default=13, help='Minimum zoom level (default: 13)')
    parser.add_argument('--zoom-max', type=int, default=16, help='Maximum zoom level (default: 16)')

    # Output
    parser.add_argument('--output', type=str, help='Output directory (default: static_maps/{provider}_tiles)')

    # Performance
    parser.add_argument('--workers', type=int, default=2,
                        help='Number of parallel downloads (default: 2, max: 6)')

    args = parser.parse_args()

    # Determine region
    if args.region:
        region = REGIONS[args.region]
        min_lat, max_lat = region['min_lat'], region['max_lat']
        min_lon, max_lon = region['min_lon'], region['max_lon']
        print(f"Using predefined region: {region['name']}")
    elif all([args.lat_min, args.lat_max, args.lon_min, args.lon_max]):
        min_lat, max_lat = args.lat_min, args.lat_max
        min_lon, max_lon = args.lon_min, args.lon_max
    else:
        parser.error("Either --region or all of --lat-min, --lat-max, --lon-min, --lon-max must be specified")
        return

    # Determine output directory
    if args.output:
        output_dir = Path(args.output)
    else:
        output_dir = Path(f"static_maps/{args.provider}_tiles")

    # Limit workers
    workers = min(args.workers, 6)

    # Download
    download_region(
        provider=args.provider,
        min_lat=min_lat,
        max_lat=max_lat,
        min_lon=min_lon,
        max_lon=max_lon,
        zoom_min=args.zoom_min,
        zoom_max=args.zoom_max,
        output_dir=output_dir,
        workers=workers
    )


if __name__ == '__main__':
    main()
