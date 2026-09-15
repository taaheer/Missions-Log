#include "missionfilter.h"
#include "missionmodel.h"

MissionFilter::MissionFilter(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
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

    QVariantMap mission{model->getMission(source_row)};
    bool isCompleted{mission.value("isCompleted").toBool()};

    if (viewStatus_ == "current")
    {
        return !isCompleted;
    }
    else if (viewStatus_ == "finished")
    {
        return isCompleted;
    }

    return false;
}