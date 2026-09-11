#ifndef MISSIONMANAGER_H
#define MISSIONMANAGER_H

#include <QAbstractListModel>
#include <QQmlEngine>

class MissionManager : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QVariantMap currentMission READ currentMission NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QVariantList currentTasks READ currentTasks  NOTIFY currentIndexChanged FINAL)
    Q_PROPERTY(QString viewStatus READ viewStatus WRITE setViewStatus NOTIFY viewStatusChanged FINAL)
public:
    enum MissionRoles{
        IdRole = Qt::UserRole + 1,
        TitleRole,
        CategoryRole,
        StatusRole,
        IsActiveRole,
        IsSuccessRole,
        TasksRole
    };
    Q_ENUM(MissionRoles)

    explicit MissionManager(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadMissions(const QString &path);
    Q_INVOKABLE void toggleMissionActive(int index);
    Q_INVOKABLE void toggleTaskCompletion(int taskIndex);
    Q_INVOKABLE void finishMission(const QString &missionId, bool isSuccess);

    int currentIndex() const {return currentIndex_;}
    void setCurrentIndex(int index);

    QVariantMap currentMission() const;
    QVariantList currentTasks() const;

    const QString& viewStatus() const {return viewStatus_;}
    void setViewStatus(const QString &status);

signals:
    void currentIndexChanged();
    void viewStatusChanged();

private:
    void updateFilteredMissions();
    void saveMissions();
    bool isValidIndex(int index) const {return index >= 0 && index < missions_.size();}
    bool areAllTasksCompleted(const QVariantMap &mission) const;

    QList<QVariantMap> allMissions_{};
    QList<QVariantMap> missions_{};
    int currentIndex_{0};
    QString viewStatus_{"current"};
};

#endif // MISSIONMANAGER_H
