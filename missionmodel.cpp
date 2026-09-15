#include "missionmodel.h"

MissionModel::MissionModel(QObject *parent)
    : QAbstractListModel{parent}
{}

int MissionModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return 0;
    }

    return missions_.size();
}

QVariant MissionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= missions_.size())
    {
        return QVariant();
    }

    const QVariantMap &mission{missions_[index.row()]};
    switch (role)
    {
    case IdRole:        return mission.value("id");
    case TitleRole:     return mission.value("title");
    case CategoryRole:  return mission.value("category");
    case StatusRole:    return mission.value("status");
    case IsActiveRole:  return mission.value("isActive");
    case IsSuccessRole: return mission.value("isSuccess");
    case TasksRole:     return mission.value("tasks");
    default:            return QVariant();
    }
}

QHash<int, QByteArray> MissionModel::roleNames() const
{
    static const QHash<int, QByteArray> roles = {
        {IdRole, "id"},
        {TitleRole, "title"},
        {CategoryRole, "category"},
        {StatusRole, "status"},
        {IsActiveRole, "isActive"},
        {IsSuccessRole, "isSuccess"},
        {TasksRole, "tasks"}
    };
    return roles;
}

void MissionModel::setMissions(const QList<QVariantMap> &missions)
{
    beginResetModel();
    missions_ = missions;
    endResetModel();
}

void MissionModel::addMission(QVariantMap mission)
{
    QString category{mission.value("category").toString()};
    mission["id"] = generateNextId(category);

    qsizetype index{missions_.size()};

    beginInsertRows(QModelIndex(), index, index);
    missions_.insert(index, mission);
    endInsertRows();
}

void MissionModel::updateMission(int row, const QVariantMap &mission)
{
    if (row >= 0 && row < missions_.size())
    {
        missions_[row] = mission;
        QModelIndex index{createIndex(row, 0)};
        emit dataChanged(index, index);
    }
}

QVariantMap MissionModel::getMission(int row) const
{
    if(row >= 0 && row < missions_.size())
    {
        return missions_[row];
    }
    return QVariantMap();
}

QList<QVariantMap> MissionModel::getAllMissions() const
{
    return missions_;
}

QString MissionModel::generateNextId(const QString &category) const
{
    const QChar prefix{(category == "side") ? QChar('s') : QChar('m')};
    int maxNum{0};

    for(const auto &mission : missions_)
    {
        QString id{mission.value("id").toString()};

        if(id.startsWith(prefix))
        {
            bool ok{false};
            int num{id.sliced(1).toInt(&ok)};
            if(ok && num > maxNum)
            {
                maxNum = num;
            }
        }
    }

    return QString(1, prefix) + QString::number(maxNum + 1);
}
