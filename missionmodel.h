#ifndef MISSIONMODEL_H
#define MISSIONMODEL_H

#include <QAbstractListModel>
#include <vector>
#include "mission.h"

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

    void setMissions(const std::vector<Mission> &missions);
    void addMission(const Mission& mission);
    void updateMission(int row, const Mission &mission);

    Mission getMission(int row) const;
    const std::vector<Mission>& getAllMissions() const;

    std::string generateNextId(const std::string &category) const;

private:
    std::vector<Mission> missions_;
};

#endif // MISSIONMODEL_H
