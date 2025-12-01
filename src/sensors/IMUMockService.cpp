#include "IMUMockService.h"
#include <QDebug>

IMUMockService::IMUMockService(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_boomAngle(0.0)
    , m_armAngle(0.0)
    , m_bucketAngle(0.0)
    , m_isDigging(false)
    , m_diggingPhase(0)
    , m_phaseProgress(0.0)
{
    // Timer'ı bağla - 16ms (yaklaşık 60 FPS)
    connect(m_timer, &QTimer::timeout, this, &IMUMockService::updateAngles);

    qDebug() << "IMUMockService initialized";
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
}

void IMUMockService::updateAngles()
{
    if (!m_isDigging) return;

    updateDiggingSequence();
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
}
