#include "missionfilter.h"
#include "missionmodel.h"

MissionFilter::MissionFilter(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    sort(0, Qt::AscendingOrder);
}

void MissionFilter::setViewStatus(const QString &status)
{
    if (viewStatus_ != status)
    {
        viewStatus_ = status;
        beginFilterChange();
        endFilterChange(QSortFilterProxyModel::Direction::Rows);
    }
}

bool MissionFilter::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    const MissionModel *model = qobject_cast<MissionModel*>(sourceModel());

    if (!model)
    {
        return false;
    }

    Mission mission{model->getMission(source_row)};

    if (viewStatus_ == "current")
    {
        return !mission.isCompleted;
    }
    else if (viewStatus_ == "finished")
    {
        return mission.isCompleted;
    }

    return false;
}

bool MissionFilter::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    const MissionModel *model = qobject_cast<MissionModel*>(sourceModel());

    if(!model)
    {
        return QSortFilterProxyModel::lessThan(source_left, source_right);
    }

    Mission mainMission{model->getMission(source_left.row())};
    Mission sideMission{model->getMission(source_right.row())};

    if (mainMission.category != sideMission.category)
    {
        return mainMission.category == "main";
    }

    return source_left.row() < source_right.row();
}