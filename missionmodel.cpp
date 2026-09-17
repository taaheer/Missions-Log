#include "missionmodel.h"

#include <QString>
#include <string_view>
#include <charconv>

MissionModel::MissionModel(QObject *parent)
    : QAbstractListModel{parent}
{}

int MissionModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return 0;
    }

    return static_cast<int>(missions_.size());
}

QVariant MissionModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() || index.row() < 0 || index.row() >= missions_.size())
    {
        return QVariant();
    }

    const Mission &mission{missions_[index.row()]};
    switch (role)
    {
    case IdRole:        return QString::fromStdString(mission.id);
    case TitleRole:     return QString::fromStdString(mission.title);
    case CategoryRole:  return QString::fromStdString(mission.category);
    case IsActiveRole:  return mission.isActive;
    case IsSuccessRole: return mission.isSuccess;
    default:            return QVariant();
    }
}

QHash<int, QByteArray> MissionModel::roleNames() const
{
    static const QHash<int, QByteArray> roles = {
        {IdRole, "id"},
        {TitleRole, "title"},
        {CategoryRole, "category"},
        {IsActiveRole, "isActive"},
        {IsSuccessRole, "isSuccess"}
    };
    return roles;
}

void MissionModel::setMissions(const std::vector<Mission> &missions)
{
    beginResetModel();
    missions_ = missions;
    endResetModel();
}

void MissionModel::addMission(const Mission& mission)
{
    Mission newMission{mission};
    newMission.id = generateNextId(newMission.category);

    int index = static_cast<int>(missions_.size());

    beginInsertRows(QModelIndex(), index, index);
    missions_.push_back(newMission);
    endInsertRows();
}

void MissionModel::updateMission(int row, const Mission &mission)
{
    if (row >= 0 && row < missions_.size())
    {
        missions_[row] = mission;
        QModelIndex index{createIndex(row, 0)};
        emit dataChanged(index, index);
    }
}

Mission MissionModel::getMission(int row) const
{
    if(row >= 0 && row < missions_.size())
    {
        return missions_[row];
    }
    return Mission();
}

const std::vector<Mission>& MissionModel::getAllMissions() const
{
    return missions_;
}

std::string MissionModel::generateNextId(const std::string &category) const
{
    const char prefix{(category == "side") ? 's' : 'm'};
    int maxNum{0};

    for(const auto &mission : missions_)
    {
        std::string_view id{mission.id};

        if(!id.empty() && id.front() == prefix)
        {
            id.remove_prefix(1);
            int num{0};
            auto [ptr, ec] = std::from_chars(id.data(), id.data() + id.size(), num);
            if(ec == std::errc() && num > maxNum)
            {
                maxNum = num;
            }
        }
    }

    return prefix + std::to_string(maxNum + 1);
}
