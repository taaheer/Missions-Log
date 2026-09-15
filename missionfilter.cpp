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

bool MissionFilter::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    const MissionModel *model = qobject_cast<MissionModel*>(sourceModel());
    if (!model) return QSortFilterProxyModel::lessThan(source_left, source_right);

    QVariantMap leftMap = model->getMission(source_left.row());
    QVariantMap rightMap = model->getMission(source_right.row());

    QString leftCat = leftMap.value("category").toString();
    QString rightCat = rightMap.value("category").toString();

    // 1. Sort by Category: "main" always comes before "side"
    if (leftCat != rightCat)
    {
        return leftCat == "main";
    }

    // 2. Secondary sorting: Keep insertion order (or sort by ID / title)
    return source_left.row() < source_right.row();
}