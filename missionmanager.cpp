#include "missionmanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <QDebug>

static QString getWritablePath()
{
    QString path{QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)};
    QDir().mkpath(path);

    return QDir(path).filePath("missions.json");
}

MissionManager::MissionManager(QObject *parent)
    : QAbstractListModel{parent}
{
    QString writablePath{getWritablePath()};

    if(!QFile::exists(writablePath))
    {
        if(!QFile::copy(":/qt/qml/MissionsLog/missions.json", writablePath))
        {
            qWarning() << "Faied to copy template file!";
        }
        else
        {
            QFile::setPermissions(writablePath, QFile::ReadOwner | QFile::WriteOwner);
        }
    }

    loadMissions(writablePath);
}


int MissionManager::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return 0;
    }

    return missions_.size();
}



QVariant MissionManager::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() || !isValidIndex(index.row()))
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



QHash<int, QByteArray> MissionManager::roleNames() const
{
    static const QHash<int, QByteArray> roles = []() {
        QHash<int, QByteArray> r;
        r[IdRole]        = "id";
        r[TitleRole]     = "title";
        r[CategoryRole]  = "category";
        r[StatusRole]    = "status";
        r[IsActiveRole]  = "isActive";
        r[IsSuccessRole] = "isSuccess";
        r[TasksRole]     = "tasks";
        return r;
    }();
    return roles;
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
        qWarning() << "FAIL: 'mission' object is missing or invalid!";
        return;
    }

    QJsonObject categories{missionsJson["mission"].toObject()};

    beginResetModel();
    allMissions_.clear();

    auto processCategory{[this](const QJsonValue &val, const QString &categoryName)
                         {
                             if(!val.isArray())
                             {
                                 return;
                             }
                             for(const QJsonValue &itemVal : val.toArray())
                             {
                                 QVariantMap missionMap{itemVal.toObject().toVariantMap()};
                                 missionMap["category"] = categoryName;
                                 allMissions_.append(missionMap);
                             }
                         }};



    if(categories.contains("main"))
    {
        processCategory(categories["main"], "main");
    }

    if(categories.contains("side"))
    {
        processCategory(categories["side"], "side");
    }

    updateFilteredMissions();
    endResetModel();
}

void MissionManager::toggleMissionActive(int index)
{
    if(!isValidIndex(index))
    {
        return;
    }

    bool currentState{missions_[index]["isActive"].toBool()};
    QString missionId{missions_[index]["id"].toString()};
    bool newState{!currentState};

    missions_[index]["isActive"] = newState;

    for(auto &mission : allMissions_)
    {
        if(mission["id"].toString() == missionId)
        {
            mission["isActive"] = newState;
            break;
        }
    }

    saveMissions();

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {IsActiveRole});
}



void MissionManager::setCurrentIndex(int index)
{
    if(currentIndex_ == index || index < 0 || !isValidIndex(index))
    {
        return;
    }

    currentIndex_ = index;
    emit currentIndexChanged();
}

void MissionManager::updateFilteredMissions()
{

    missions_.clear();

    for(const QVariant &item : allMissions_)
    {
        QVariantMap mission{item.toMap()};

        bool isCompleted{mission["isCompleted"].toBool()};

        if(viewStatus_ == "current" && !isCompleted)
        {
            missions_.append(mission);
        }
        else if(viewStatus_ == "finished" && isCompleted)
        {
            missions_.append(mission);
        }

    }
}

void MissionManager::saveMissions()
{
    QJsonObject categories{};
    QJsonArray main{};
    QJsonArray side{};

    for(const auto &missionMap : allMissions_)
    {
        QJsonObject mission{QJsonObject::fromVariantMap(missionMap)};

        QString cat{mission["category"].toString()};
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

    QJsonObject rootObj{
        {"mission", categories}
    };

    QString path{getWritablePath()};
    QFile file{path};

    if (file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
    {
        file.write(QJsonDocument(rootObj).toJson(QJsonDocument::Indented));
        file.close();
    }
    else
    {
        qWarning() << "Failed to save missions to path:" << path;
    }
}

bool MissionManager::areAllTasksCompleted(const QVariantMap &mission) const
{
    auto checkList = [](const QVariantList &list)
    {
        for(const auto &item : list)
        {
            if(!item.toMap().value("isCompleted").toBool())
            {
                return false;
            }
        }

        return true;
    };

    return checkList(mission["primary"].toList()) && checkList(mission["secondary"].toList());
}

void MissionManager::setViewStatus(const QString &status)
{
    if(viewStatus_ == status)
    {
        return;
    }

    beginResetModel();

    viewStatus_ = status;
    updateFilteredMissions();
    currentIndex_ = (missions_.isEmpty() ? -1 : 0);

    endResetModel();

    emit viewStatusChanged();
    emit currentIndexChanged();
}

QVariantMap MissionManager::currentMission() const
{
    if(!isValidIndex(currentIndex_))
    {
        return QVariantMap();
    }
    return missions_[currentIndex_];
}

QVariantList MissionManager::currentTasks() const
{
    if(!isValidIndex(currentIndex_))
    {
        return QVariantList();
    }

    const QVariantMap mission{currentMission()};

    QVariantList combinedTasks;

    auto processObjectiveList = [](const QVariantList &tasks, const QString &sectionName, int indexOffset)
    {
        QVariantList unlocked;
        bool isBlocked{false};

        for(int i{0}; i < tasks.size(); ++i)
        {
            QVariantMap temp{tasks[i].toMap()};
            temp["section"] = sectionName;
            temp["originalIndex"] = indexOffset + i;

            bool isDone{temp["isCompleted"].toBool()};
            if(isBlocked)
            {
                break;
            }

            unlocked.append(temp);

            if(!isDone)
            {
                isBlocked = true;
            }
        }

        QVariantList reversed;
        for(int i{unlocked.size() - 1}; i >= 0; --i)
        {
            reversed.append(unlocked[i]);
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
    if(!isValidIndex(currentIndex_))
    {
        return;
    }

    QVariantMap &currentMissionMap{missions_[currentIndex_]};

    auto toggleInList = [&currentMissionMap](const QString &key, int index)
    {
        // Why uniform initialization doesn't work properly
        QVariantList list = currentMissionMap[key].toList();

        if(index >= 0 && index < list.size())
        {
            QVariantMap task = list[index].toMap();
            task["isCompleted"] = !task["isCompleted"].toBool();
            list[index] = task;
            currentMissionMap[key] = list;
            return true;
        }
        return false;
    };

    QVariantList primaryTasks = currentMissionMap["primary"].toList();
    bool changed{false};

    if(taskIndex < primaryTasks.size())
    {
        changed = toggleInList("primary", taskIndex);
    }
    else
    {
        changed = toggleInList("secondary", taskIndex - primaryTasks.size());
    }

    if(!changed)
    {
        return;
    }

    QString missionId = currentMissionMap["id"].toString();
    for(auto &mission : allMissions_)
    {
        if(mission["id"].toString() == missionId)
        {
            mission = currentMissionMap;
            break;
        }
    }

    if(areAllTasksCompleted(currentMissionMap))
    {
        bool missionSuccess{true};
        finishMission(missionId, missionSuccess);
    }

    saveMissions();

    QModelIndex modelIndex = createIndex(currentIndex_, 0);
    emit dataChanged(modelIndex, modelIndex, {TasksRole});}



void MissionManager::finishMission(const QString &missionId, bool isSuccess)
{
    bool found{false};
    for(auto &mission : allMissions_)
    {
        if(mission["id"].toString() == missionId)
        {
            mission["isCompleted"] = true;
            mission["isSuccess"] = isSuccess;
            mission["isActive"] = false;
            found = true;
            break;
        }
    }

    if(!found)
    {
        return;
    }

    saveMissions();

    beginResetModel();
    updateFilteredMissions();

    if (missions_.isEmpty())
    {
        currentIndex_ = -1;
    }
    else if (currentIndex_ >= missions_.size())
    {
        currentIndex_ = missions_.size() - 1;
    }
    endResetModel();

    emit currentIndexChanged();
}

