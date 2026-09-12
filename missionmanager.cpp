#include "missionmanager.h"
#include "missionmodel.h"
#include "missionfilter.h"
#include <QStandardPaths>
#include <QDir>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <ranges>
#include <QDebug>

static QString getWritablePath()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(path);

    return QDir(path).filePath("missions.json");
}

MissionManager::MissionManager(QObject *parent)
    : QObject{parent},
    sourceModel_(new MissionModel(this)),
    filterModel_(new MissionFilter(this))
{
    filterModel_->setSourceModel(sourceModel_);

    QString writablePath{getWritablePath()};

    if (!QFile::exists(writablePath))
    {
        if (!QFile::copy(":/qt/qml/MissionsLog/missions.json", writablePath))
        {
            qWarning() << "Failed to copy template file!";
        }
        else
        {
            QFile::setPermissions(writablePath, QFile::ReadOwner | QFile::WriteOwner);
        }
    }

    loadMissions(writablePath);
}

QObject* MissionManager::proxyModel() const {
    return filterModel_;
}

const QString& MissionManager::viewStatus() const {
    return filterModel_->viewStatus();
}

void MissionManager::setViewStatus(const QString &status)
{
    if (filterModel_->viewStatus() != status)
    {
        filterModel_->setViewStatus(status);

        int nextIndex = (filterModel_->rowCount() > 0) ? 0 : -1;

        currentIndex_ = nextIndex;
        emit currentIndexChanged();

        emit viewStatusChanged();
    }
}

void MissionManager::loadMissions(const QString &path)
{
    QFile file{path};

    if(!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qWarning() << "Failed to open mission file at path:" << path;
        return;
    }

    QByteArray jsonData{file.readAll()};
    file.close();

    QJsonParseError parseError;

    QJsonDocument doc{QJsonDocument::fromJson(jsonData, &parseError)};

    if(parseError.error != QJsonParseError::NoError)
    {
        qWarning() << "JSON Parse Error: " << parseError.errorString();
        return;
    }

    if(!doc.isObject())
    {
        qWarning() << "FAIL: Document is not an object!";
        return;
    }

    QJsonObject missionsJson{doc.object()};

    if(!missionsJson.contains("mission") || !missionsJson["mission"].isObject())
    {
        qWarning() << "Fail: 'mission' object is missing or invalid!";
        return;
    }

    QJsonObject categories{missionsJson["mission"].toObject()};

    QList<QVariantMap> loadedMissions;

    auto processCategory = [&loadedMissions](const QJsonValue &val, const QString &categoryName)
    {
        if (!val.isArray())
        {
            return;
        }

        for (const QJsonValue &itemVal : val.toArray())
        {
            QVariantMap missionMap{itemVal.toObject().toVariantMap()};
            missionMap["category"] = categoryName;
            loadedMissions.append(missionMap);
        }
    };

    if(categories.contains("main"))
    {
        processCategory(categories["main"], "main");
    }

    if (categories.contains("side"))
    {
        processCategory(categories["side"], "side");
    }

    sourceModel_->setMissions(loadedMissions);
    setCurrentIndex(filterModel_->rowCount() > 0 ? 0 : -1);
}

void MissionManager::toggleMissionActive(int proxyIndex)
{
    if(proxyIndex < 0 || proxyIndex >= filterModel_->rowCount())
    {
        return;
    }

    QModelIndex sourceIdx = filterModel_->mapToSource(filterModel_->index(proxyIndex, 0));
    int sourceRow = sourceIdx.row();

    QVariantMap mission = sourceModel_->getMission(sourceRow);
    mission["isActive"] = !mission.value("isActive").toBool();

    sourceModel_->updateMission(sourceRow, mission);
    saveMissions();
}

void MissionManager::setCurrentIndex(int index)
{
    if(currentIndex_ == index || index < -1 || index >= filterModel_->rowCount())
    {
        return;
    }

    currentIndex_ = index;
    emit currentIndexChanged();
}

QVariantMap MissionManager::currentMission() const
{
    if(currentIndex_ < 0 || currentIndex_ >= filterModel_->rowCount())
    {
        return QVariantMap();
    }

    QModelIndex sourceIdx = filterModel_->mapToSource(filterModel_->index(currentIndex_, 0));
    return sourceModel_->getMission(sourceIdx.row());
}

QVariantList MissionManager::currentTasks() const
{
    if(currentIndex_ < 0 || currentIndex_ >= filterModel_->rowCount())
    {
        return QVariantList();
    }

    const QVariantMap mission{currentMission()};

    QVariantList combinedTasks;

    auto processObjectiveList = [](const QVariantList &tasks, const QString &sectionName, int indexOffset)
    {
        QVariantList unlocked;
        bool isBlocked{false};

        for (int i{0}; i < tasks.size(); ++i)
        {
            QVariantMap temp = tasks[i].toMap();
            temp["section"] = sectionName;
            temp["originalIndex"] = indexOffset + i;

            if(isBlocked)
            {
                break;
            }

            unlocked.append(temp);

            if(!temp.value("isCompleted").toBool())
            {
                isBlocked = true;
            }
        }

        QVariantList reversed;
        reversed.reserve(unlocked.size());
        for(const auto &item : unlocked | std::views::reverse)
        {
            reversed.append(item);
        }

        return reversed;
    };

    // Why uniform initialization causing task to be empty
    QVariantList primaryTasks = mission.value("primary").toList();
    QVariantList secondaryTasks = mission.value("secondary").toList();

    combinedTasks.append(processObjectiveList(primaryTasks, "PRIMARY OBJECTIVES", 0));
    combinedTasks.append(processObjectiveList(secondaryTasks, "SECONDARY OBJECTIVES", primaryTasks.size()));

    return combinedTasks;
}

void MissionManager::toggleTaskCompletion(int taskIndex)
{
    if(currentIndex_ < 0 || currentIndex_ >= filterModel_->rowCount())
    {
        return;
    }

    QModelIndex sourceIdx = filterModel_->mapToSource(filterModel_->index(currentIndex_, 0));
    int sourceRow = sourceIdx.row();

    QVariantMap currentMissionMap{sourceModel_->getMission(sourceRow)};

    auto toggleInList = [&currentMissionMap](const QString &key, int idx)
    {
        QVariantList list = currentMissionMap.value(key).toList();

        if (idx >= 0 && idx < list.size())
        {
            QVariantMap task = list[idx].toMap();
            task["isCompleted"] = !task.value("isCompleted").toBool();
            list[idx] = task;
            currentMissionMap[key] = list;
            return true;
        }
        return false;
    };

    QVariantList primaryTasks = currentMissionMap.value("primary").toList();
    bool changed = (taskIndex < primaryTasks.size()) ? toggleInList("primary", taskIndex) : toggleInList("secondary", taskIndex - primaryTasks.size());

    if(!changed)
    {
        return;
    }


    if (areAllTasksCompleted(currentMissionMap))
    {
        currentMissionMap["isCompleted"] = true;
        currentMissionMap["isSuccess"] = true;
        currentMissionMap["isActive"] = false;
    }

    sourceModel_->updateMission(sourceRow, currentMissionMap);

    saveMissions();

    if(filterModel_->rowCount() == 0)
    {
        setCurrentIndex(-1);
    }
    else if(currentIndex_ >= filterModel_->rowCount())
    {
        setCurrentIndex(filterModel_->rowCount() - 1);
    }
    else
    {
        emit currentIndexChanged();
    }
}


void MissionManager::saveMissions()
{
    QJsonObject categories;
    QJsonArray main, side;

    for (const auto &missionMap : sourceModel_->getAllMissions())
    {
        QJsonObject mission = QJsonObject::fromVariantMap(missionMap);

        QString cat{mission.value("category").toString()};
        mission.remove("category");

        if(cat == "side")
        {
            side.append(mission);
        }
        else
        {
            main.append(mission);
        }
    }

    categories["main"] = main;
    categories["side"] = side;

    QJsonObject rootObj{{"mission", categories}};

    QString path = getWritablePath();
    QFile file{path};

    if(file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
    {
        file.write(QJsonDocument(rootObj).toJson(QJsonDocument::Indented));
        file.close();
    }
    else
    {
        qWarning() << "Failed to save missions to path: " << path;
    }
}

bool MissionManager::areAllTasksCompleted(const QVariantMap &mission) const
{
    auto checkList = [](const QVariantList &list)
    {
        return std::ranges::all_of(list, [](const QVariant &item){
            return item.toMap().value("isCompleted").toBool();
        });
    };

    return checkList(mission.value("primary").toList()) && checkList(mission.value("secondary").toList());
}

int MissionManager::sourceIndexFromMissionId(const QString &missionId) const
{
    const auto missions = sourceModel_->getAllMissions();

    for(auto [i, mission] : missions | std::views::enumerate)
    {
        if(mission.value("id").toString() == missionId)
        {
            return static_cast<int>(i);
        }
    }

    return -1;
}