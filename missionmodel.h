#ifndef MISSIONMODEL_H
#define MISSIONMODEL_H

#include <QAbstractListModel>

class MissionModel : public QAbstractListModel
{
    Q_OBJECT
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

    explicit MissionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setMissions(const QList<QVariantMap> &missions);
    void addMission(QVariantMap mission);
    void updateMission(int row, const QVariantMap &mission);

    QVariantMap getMission(int row) const;
    QList<QVariantMap> getAllMissions() const;

    QString generateNextId(const QString &category) const;

private:
    QList<QVariantMap> missions_;
};

#endif // MISSIONMODEL_H
