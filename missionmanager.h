#ifndef MISSIONMANAGER_H
#define MISSIONMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QVariantMap>
#include <QVariantList>

class MissionModel;
class MissionFilter;

class MissionManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QObject* proxyModel READ proxyModel CONSTANT)

    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QVariantMap currentMission READ currentMission NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QVariantList currentTasks READ currentTasks NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QString viewStatus READ viewStatus WRITE setViewStatus NOTIFY viewStatusChanged FINAL)

public:
    explicit MissionManager(QObject *parent = nullptr);

    QObject* proxyModel() const;

    Q_INVOKABLE void loadMissions(const QString &path);
    Q_INVOKABLE void toggleMissionActive(int proxyIndex);
    Q_INVOKABLE void toggleTaskCompletion(int taskIndex);

    int currentIndex() const { return currentIndex_; }
    void setCurrentIndex(int index);

    QVariantMap currentMission() const;
    QVariantList currentTasks() const;

    const QString& viewStatus() const;
    void setViewStatus(const QString &status);

signals:
    void currentIndexChanged();
    void viewStatusChanged();

private:
    void saveMissions();
    bool areAllTasksCompleted(const QVariantMap &mission) const;
    int sourceIndexFromMissionId(const QString &missionId) const;

    MissionModel *sourceModel_{nullptr};
    MissionFilter *filterModel_{nullptr};

    int currentIndex_{0};
};

#endif // MISSIONMANAGER_H