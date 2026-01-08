#include "IMUMockService.h"
#include <QDebug>

IMUMockService::IMUMockService(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_boomAngle(0.0)
    , m_armAngle(0.0)
    , m_bucketAngle(0.0)
    , m_bucketDepth(0.0)
    , m_isDigging(false)
    , m_diggingPhase(0)
    , m_phaseProgress(0.0)
    , m_isRandomMode(false)
    , m_randomBoomTarget(0.0)
    , m_randomArmTarget(0.0)
    , m_randomBucketTarget(0.0)
{
    // Timer'ı bağla - 16ms (yaklaşık 60 FPS)
    connect(m_timer, &QTimer::timeout, this, &IMUMockService::updateAngles);

    // İlk derinliği hesapla
    calculateBucketDepth();

    qDebug() << "IMUMockService initialized";
}

void IMUMockService::calculateBucketDepth()
{
    // Ekskavatör kol uzunlukları (metre)
    const double BOOM_LENGTH = 6.0;   // Ana kol
    const double ARM_LENGTH = 4.0;    // Ön kol
    const double BUCKET_LENGTH = 1.5; // Kepçe
    const double PIVOT_HEIGHT = 2.0;  // Döner eksenin yerden yüksekliği

    // Açıları radyana çevir
    double boomRad = qDegreesToRadians(m_boomAngle);
    double armRad = qDegreesToRadians(m_armAngle);
    double bucketRad = qDegreesToRadians(m_bucketAngle);

    // Kepçe ucu pozisyonunu hesapla (basitleştirilmiş kinematik)
    // Negatif açılar aşağıyı gösterir
    double boomEndY = PIVOT_HEIGHT - BOOM_LENGTH * qSin(boomRad);
    double armEndY = boomEndY - ARM_LENGTH * qSin(boomRad + armRad);
    double bucketEndY = armEndY - BUCKET_LENGTH * qSin(boomRad + armRad + bucketRad);

    // Derinlik = su seviyesinden (0) aşağıya doğru negatif
    double newDepth = -bucketEndY;

    if (qAbs(newDepth - m_bucketDepth) > 0.01) {
        m_bucketDepth = newDepth;
        emit bucketDepthChanged();
    }
}

void IMUMockService::startDigging()
{
    if (!m_isDigging) {
        qDebug() << "Starting digging simulation";
        m_isDigging = true;
        m_diggingPhase = 0;
        m_phaseProgress = 0.0;
        m_timer->start(16); // ~60 FPS
        emit isDiggingChanged();
    }
}

void IMUMockService::stopDigging()
{
    if (m_isDigging) {
        qDebug() << "Stopping digging simulation";
        m_isDigging = false;
        m_timer->stop();
        emit isDiggingChanged();
    }
}

void IMUMockService::reset()
{
    qDebug() << "Resetting IMU angles";
    stopDigging();

    m_boomAngle = 0.0;
    m_armAngle = 0.0;
    m_bucketAngle = 0.0;
    m_diggingPhase = 0;
    m_phaseProgress = 0.0;

    emit boomAngleChanged();
    emit armAngleChanged();
    emit bucketAngleChanged();

    calculateBucketDepth();
}

void IMUMockService::updateAngles()
{
    if (m_isDigging) {
        updateDiggingSequence();
    } else if (m_isRandomMode) {
        updateRandomMovement();
    }
}

void IMUMockService::updateDiggingSequence()
{
    // İlerlemeyi artır
    m_phaseProgress += PHASE_SPEED;

    // Smooth interpolation için easing function (ease in-out)
    auto easeInOutQuad = [](double t) -> double {
        return t < 0.5 ? 2 * t * t : 1 - qPow(-2 * t + 2, 2) / 2;
    };

    double easedProgress = easeInOutQuad(qBound(0.0, m_phaseProgress, 1.0));

    switch (m_diggingPhase) {
        case 0: // Başlangıç pozisyonu - Kolu ileriye uzat
            m_boomAngle = easedProgress * 10.0;
            m_armAngle = easedProgress * 15.0;
            m_bucketAngle = easedProgress * 10.0;

            if (m_phaseProgress >= 1.0) {
                m_diggingPhase = 1;
                m_phaseProgress = 0.0;
                qDebug() << "Phase 1: Lowering boom";
            }
            break;

        case 1: // İniş - Kolu aşağı indir
            m_boomAngle = 10.0 + easedProgress * (BOOM_MIN - 10.0);
            m_armAngle = 15.0 + easedProgress * (ARM_MIN - 15.0);
            m_bucketAngle = 10.0 + easedProgress * 5.0;

            if (m_phaseProgress >= 1.0) {
                m_diggingPhase = 2;
                m_phaseProgress = 0.0;
                qDebug() << "Phase 2: Digging";
            }
            break;

        case 2: // Kazı - Kova ile toprağı kaz
            m_boomAngle = BOOM_MIN + easedProgress * 2.0;
            m_armAngle = ARM_MIN + easedProgress * (ARM_MAX - ARM_MIN) * 0.6;
            m_bucketAngle = 15.0 + easedProgress * (BUCKET_MIN - 15.0);

            if (m_phaseProgress >= 1.0) {
                m_diggingPhase = 3;
                m_phaseProgress = 0.0;
                qDebug() << "Phase 3: Lifting";
            }
            break;

        case 3: // Kaldırma - Toprağı yukarı kaldır
            m_boomAngle = BOOM_MIN + 2.0 + easedProgress * (BOOM_MAX - (BOOM_MIN + 2.0));
            m_armAngle = ARM_MIN + (ARM_MAX - ARM_MIN) * 0.6 - easedProgress * 20.0;
            m_bucketAngle = BUCKET_MIN + easedProgress * 5.0;

            if (m_phaseProgress >= 1.0) {
                m_diggingPhase = 4;
                m_phaseProgress = 0.0;
                qDebug() << "Phase 4: Dumping";
            }
            break;

        case 4: // Boşaltma - Toprağı dök
            m_boomAngle = BOOM_MAX;
            m_armAngle = ARM_MIN + (ARM_MAX - ARM_MIN) * 0.6 - 20.0;
            m_bucketAngle = BUCKET_MIN + 5.0 + easedProgress * (BUCKET_MAX - (BUCKET_MIN + 5.0));

            if (m_phaseProgress >= 1.0) {
                m_diggingPhase = 0;
                m_phaseProgress = 0.0;
                qDebug() << "Digging cycle completed - restarting";
                emit diggingCycleCompleted();
            }
            break;
    }

    // Sinyalleri gönder
    emit boomAngleChanged();
    emit armAngleChanged();
    emit bucketAngleChanged();

    // Kepçe derinliğini hesapla
    calculateBucketDepth();
}

// Manuel kontrol metodları
void IMUMockService::setBoomAngle(double angle)
{
    // Otomatik kazı veya rastgele modundaysa manuel kontrolü devre dışı bırak
    if (m_isDigging || m_isRandomMode) {
        return;
    }

    double clampedAngle = qBound(BOOM_MIN, angle, BOOM_MAX);
    if (qAbs(m_boomAngle - clampedAngle) > 0.01) {
        m_boomAngle = clampedAngle;
        emit boomAngleChanged();
        calculateBucketDepth();
    }
}

void IMUMockService::setArmAngle(double angle)
{
    // Otomatik kazı veya rastgele modundaysa manuel kontrolü devre dışı bırak
    if (m_isDigging || m_isRandomMode) {
        return;
    }

    double clampedAngle = qBound(ARM_MIN, angle, ARM_MAX);
    if (qAbs(m_armAngle - clampedAngle) > 0.01) {
        m_armAngle = clampedAngle;
        emit armAngleChanged();
        calculateBucketDepth();
    }
}

void IMUMockService::setBucketAngle(double angle)
{
    // Otomatik kazı modundaysa manuel kontrolü devre dışı bırak
    if (m_isDigging || m_isRandomMode) {
        return;
    }

    double clampedAngle = qBound(BUCKET_MIN, angle, BUCKET_MAX);
    if (qAbs(m_bucketAngle - clampedAngle) > 0.01) {
        m_bucketAngle = clampedAngle;
        emit bucketAngleChanged();
        calculateBucketDepth();
    }
}

// Rastgele hareket modu fonksiyonları
void IMUMockService::startRandomMovement()
{
    if (!m_isRandomMode && !m_isDigging) {
        qDebug() << "Starting random movement mode";
        m_isRandomMode = true;

        // İlk rastgele hedefleri ayarla
        m_randomBoomTarget = BOOM_MIN + (qrand() % 100) / 100.0 * (BOOM_MAX - BOOM_MIN);
        m_randomArmTarget = ARM_MIN + (qrand() % 100) / 100.0 * (ARM_MAX - ARM_MIN);
        m_randomBucketTarget = BUCKET_MIN + (qrand() % 100) / 100.0 * (BUCKET_MAX - BUCKET_MIN);

        m_timer->start(16); // ~60 FPS
        emit isRandomModeChanged();
    }
}

void IMUMockService::stopRandomMovement()
{
    if (m_isRandomMode) {
        qDebug() << "Stopping random movement mode";
        m_isRandomMode = false;
        m_timer->stop();
        emit isRandomModeChanged();
    }
}

void IMUMockService::updateRandomMovement()
{
    // Her açı için smooth interpolation
    const double SPEED = 0.5; // Hareket hızı

    // Boom hareketi
    double boomDiff = m_randomBoomTarget - m_boomAngle;
    if (qAbs(boomDiff) < 1.0) {
        // Hedefe ulaşıldı, yeni hedef belirle
        m_randomBoomTarget = BOOM_MIN + (qrand() % 100) / 100.0 * (BOOM_MAX - BOOM_MIN);
    } else {
        m_boomAngle += boomDiff * SPEED * 0.016; // 60 FPS için normalize
        emit boomAngleChanged();
    }

    // Arm hareketi
    double armDiff = m_randomArmTarget - m_armAngle;
    if (qAbs(armDiff) < 1.0) {
        m_randomArmTarget = ARM_MIN + (qrand() % 100) / 100.0 * (ARM_MAX - ARM_MIN);
    } else {
        m_armAngle += armDiff * SPEED * 0.016;
        emit armAngleChanged();
    }

    // Bucket hareketi
    double bucketDiff = m_randomBucketTarget - m_bucketAngle;
    if (qAbs(bucketDiff) < 1.0) {
        m_randomBucketTarget = BUCKET_MIN + (qrand() % 100) / 100.0 * (BUCKET_MAX - BUCKET_MIN);
    } else {
        m_bucketAngle += bucketDiff * SPEED * 0.016;
        emit bucketAngleChanged();
    }

    // Kepçe derinliğini hesapla
    calculateBucketDepth();
}
