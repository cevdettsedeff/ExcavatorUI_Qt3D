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
    Q_PROPERTY(double bucketDepth READ bucketDepth NOTIFY bucketDepthChanged)
    Q_PROPERTY(bool isDigging READ isDigging NOTIFY isDiggingChanged)
    Q_PROPERTY(bool isRandomMode READ isRandomMode NOTIFY isRandomModeChanged)

public:
    explicit IMUMockService(QObject *parent = nullptr);

    double boomAngle() const { return m_boomAngle; }
    double armAngle() const { return m_armAngle; }
    double bucketAngle() const { return m_bucketAngle; }
    double bucketDepth() const { return m_bucketDepth; }
    bool isDigging() const { return m_isDigging; }
    bool isRandomMode() const { return m_isRandomMode; }

    // QML'den çağrılabilir metodlar
    Q_INVOKABLE void startDigging();
    Q_INVOKABLE void stopDigging();
    Q_INVOKABLE void reset();

    // Manuel kontrol metodları
    Q_INVOKABLE void setBoomAngle(double angle);
    Q_INVOKABLE void setArmAngle(double angle);
    Q_INVOKABLE void setBucketAngle(double angle);

    // Rastgele hareket modu
    Q_INVOKABLE void startRandomMovement();
    Q_INVOKABLE void stopRandomMovement();

signals:
    void boomAngleChanged();
    void armAngleChanged();
    void bucketAngleChanged();
    void bucketDepthChanged();
    void isDiggingChanged();
    void isRandomModeChanged();
    void diggingCycleCompleted();

private slots:
    void updateAngles();

private:
    void updateDiggingSequence();
    void updateRandomMovement();
    void calculateBucketDepth();

    QTimer* m_timer;

    // Açı değerleri
    double m_boomAngle;      // Boom (ana kol) açısı
    double m_armAngle;       // Arm (ön kol) açısı
    double m_bucketAngle;    // Bucket (kova) açısı
    double m_bucketDepth;    // Kepçe derinliği (metre)

    // Simülasyon durumu
    bool m_isDigging;
    int m_diggingPhase;      // 0: başlangıç, 1: iniş, 2: kazı, 3: kaldırma, 4: boşaltma
    double m_phaseProgress;   // Mevcut faz ilerlemesi (0.0 - 1.0)

    // Rastgele hareket modu
    bool m_isRandomMode;
    double m_randomBoomTarget;
    double m_randomArmTarget;
    double m_randomBucketTarget;

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
