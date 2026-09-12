#ifndef MISSIONFILTER_H
#define MISSIONFILTER_H

#include <QSortFilterProxyModel>

class MissionFilter : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit MissionFilter(QObject *parent = nullptr);

    const QString& viewStatus() const { return viewStatus_; }
    void setViewStatus(const QString &status);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    QString viewStatus_{"current"};
};

#endif // MISSIONFILTER_H
