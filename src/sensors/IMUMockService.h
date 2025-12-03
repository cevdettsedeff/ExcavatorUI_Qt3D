#ifndef IMUMOCKSERVICE_H
#define IMUMOCKSERVICE_H

#include <QObject>
#include <QTimer>
#include <QtMath>

class IMUMockService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double boomAngle READ boomAngle NOTIFY boomAngleChanged)
    Q_PROPERTY(double armAngle READ armAngle NOTIFY armAngleChanged)
    Q_PROPERTY(double bucketAngle READ bucketAngle NOTIFY bucketAngleChanged)
    Q_PROPERTY(bool isDigging READ isDigging NOTIFY isDiggingChanged)

public:
    explicit IMUMockService(QObject *parent = nullptr);

    double boomAngle() const { return m_boomAngle; }
    double armAngle() const { return m_armAngle; }
    double bucketAngle() const { return m_bucketAngle; }
    bool isDigging() const { return m_isDigging; }

    // QML'den çağrılabilir metodlar
    Q_INVOKABLE void startDigging();
    Q_INVOKABLE void stopDigging();
    Q_INVOKABLE void reset();

signals:
    void boomAngleChanged();
    void armAngleChanged();
    void bucketAngleChanged();
    void isDiggingChanged();
    void diggingCycleCompleted();

private slots:
    void updateAngles();

private:
    void updateDiggingSequence();

    QTimer* m_timer;

    // Açı değerleri
    double m_boomAngle;      // Boom (ana kol) açısı
    double m_armAngle;       // Arm (ön kol) açısı
    double m_bucketAngle;    // Bucket (kova) açısı

    // Simülasyon durumu
    bool m_isDigging;
    int m_diggingPhase;      // 0: başlangıç, 1: iniş, 2: kazı, 3: kaldırma, 4: boşaltma
    double m_phaseProgress;   // Mevcut faz ilerlemesi (0.0 - 1.0)

    // Kazı hareketi parametreleri
    static constexpr double BOOM_MIN = -15.0;
    static constexpr double BOOM_MAX = 35.0;
    static constexpr double ARM_MIN = -45.0;
    static constexpr double ARM_MAX = 25.0;
    static constexpr double BUCKET_MIN = -60.0;
    static constexpr double BUCKET_MAX = 40.0;

    static constexpr double PHASE_SPEED = 0.008;  // Her update'te ilerleme miktarı
};

#endif // IMUMOCKSERVICE_H
