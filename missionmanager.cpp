#include "missionmanager.h"
#include "missionmodel.h"
#include "missionfilter.h"
#include "mission.h"

#include <QStandardPaths>
#include <QDir>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QString>

#include <ranges>
#include <filesystem>

namespace fs = std::filesystem;

static QString getWritablePath()
{
    fs::path path{QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation).toStdString()};
    fs::create_directories(path);

    path /= "missions.json";

    return QString::fromStdString(path.string());
}

static Task parseTask(const QJsonObject obj)
{
    Task task;
    task.name = obj["name"].toString().toStdString();
    task.detail = obj["detail"].toString().toStdString();
    task.isCompleted = obj["isCompleted"].toBool();

    return task;
}

static Mission parseMission(const QJsonObject& obj, const std::string& defaultCategory)
{
    Mission mission;
    mission.id = obj["id"].toString().toStdString();
    mission.title = obj["title"].toString().toStdString();
    mission.category = obj.contains("category") ? obj["category"].toString().toStdString() : defaultCategory;
    mission.isActive = obj["isActive"].toBool();
    mission.isCompleted = obj["isCompleted"].toBool();
    mission.isSuccess = obj["isSuccess"].toBool();

    if(obj.contains("primary"))
    {
        for(const auto& task : obj["primary"].toArray())
        {
            mission.primary.push_back(parseTask(task.toObject()));
        }
    }

    if(obj.contains("secondary"))
    {
        for(const auto& task : obj["secondary"].toArray())
        {
            mission.secondary.push_back(parseTask(task.toObject()));
        }
    }

    return mission;
}

static QJsonObject taskToJson(const Task& task)
{
    QJsonObject obj;

    obj["name"] = QString::fromStdString(task.name);
    obj["detail"] = QString::fromStdString(task.detail);
    obj["isCompleted"] = task.isCompleted;

    return obj;
}


MissionManager::MissionManager(QObject *parent)
    : QObject{parent},
    sourceModel_(new MissionModel(this)),
    filterModel_(new MissionFilter(this))
{
    filterModel_->setSourceModel(sourceModel_);

    QString writablePath{getWritablePath()};

    if(!QFile::exists(writablePath))
    {
        if(!QFile::copy(":/qt/qml/MissionsLog/missions.json", writablePath))
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
    if(filterModel_->viewStatus() != status)
    {
        filterModel_->setViewStatus(status);

        int nextIndex{(filterModel_->rowCount() > 0) ? 0 : -1};

        currentIndex_ = nextIndex;

        emit currentIndexChanged();
        emit viewStatusChanged();
    }
}

bool MissionManager::isValidIndex(int index) const
{
    return index >= 0 && index < filterModel_->rowCount();
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

    std::vector<Mission> loadedMissions;

    size_t totalSize{0};
    QJsonArray main;
    QJsonArray side;

    if(categories.contains("main"))
    {
        main = categories["main"].toArray();
        totalSize += main.size();
    }

    if(categories.contains("side"))
    {
        side = categories["side"].toArray();
        totalSize += side.size();
    }

    loadedMissions.reserve(totalSize);

    if(!main.isEmpty())
    {
        std::ranges::copy(main | std::views::transform([](const QJsonValue& mission) {
                              return parseMission(mission.toObject(), "main");
                          }),
                          std::back_inserter(loadedMissions)
                          );
    }

    if(!side.isEmpty())
    {
        std::ranges::copy(side | std::views::transform([](const QJsonValue& mission) {
                              return parseMission(mission.toObject(), "side");
                          }),
                          std::back_inserter(loadedMissions)
                          );
    }

    sourceModel_->setMissions(loadedMissions);
    setCurrentIndex(filterModel_->rowCount() > 0 ? 0 : -1);
}

void MissionManager::toggleMissionActive(int proxyIndex)
{
    if(!isValidIndex(proxyIndex))
    {
        return;
    }

    QModelIndex sourceIndex{filterModel_->mapToSource(filterModel_->index(proxyIndex, 0))};
    int sourceRow{sourceIndex.row()};

    Mission mission{sourceModel_->getMission(sourceRow)};
    mission.isActive = !mission.isActive;

    sourceModel_->updateMission(sourceRow, mission);
    saveMissions();
}

void MissionManager::setCurrentIndex(int index)
{
    if(currentIndex_ == index || index >= 0 && !isValidIndex(index))
    {
        return;
    }

    currentIndex_ = index;
    emit currentIndexChanged();
}

QVariantMap MissionManager::currentMission() const
{
    if(!isValidIndex(currentIndex_))
    {
        return QVariantMap();
    }

    QModelIndex sourceIndex{filterModel_->mapToSource(filterModel_->index(currentIndex_, 0))};
    Mission m{sourceModel_->getMission(sourceIndex.row())};

    QVariantMap map;
    map["id"] = QString::fromStdString(m.id);
    map["title"] = QString::fromStdString(m.title);
    map["category"] = QString::fromStdString(m.category);
    map["isActive"] = m.isActive;
    map["isCompleted"] = m.isCompleted;
    map["isSuccess"] = m.isSuccess;

    return map;
}

QVariantList MissionManager::currentTasks() const
{
    if(!isValidIndex(currentIndex_))
    {
        return QVariantList();
    }

    QModelIndex sourceIndex{filterModel_->mapToSource(filterModel_->index(currentIndex_, 0))};

    Mission mission{sourceModel_->getMission(sourceIndex.row())};

    QVariantList combinedTasks;

    auto processObjectiveList = [](const std::vector<Task> &tasks, const QString &sectionName, int indexOffset)
    {
        QVariantList unlocked;
        bool isBlocked{false};

        for(size_t i{0}; i < tasks.size(); ++i)
        {
            QVariantMap temp;
            temp["name"] = QString::fromStdString(tasks[i].name);
            temp["detail"] = QString::fromStdString(tasks[i].detail);
            temp["isCompleted"] = tasks[i].isCompleted;
            temp["section"] = sectionName;
            temp["originalIndex"] = indexOffset + static_cast<int>(i);

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

    combinedTasks.append(processObjectiveList(mission.primary, "PRIMARY OBJECTIVES", 0));
    combinedTasks.append(processObjectiveList(mission.secondary, "SECONDARY OBJECTIVES", static_cast<int>(mission.primary.size())));

    return combinedTasks;
}

void MissionManager::toggleTaskCompletion(int taskIndex)
{
    if(!isValidIndex(currentIndex_))
    {
        return;
    }

    QModelIndex sourceIndex{filterModel_->mapToSource(filterModel_->index(currentIndex_, 0))};
    int sourceRow{sourceIndex.row()};

    Mission mission{sourceModel_->getMission(sourceRow)};

    bool changed{false};

    if(taskIndex < mission.primary.size())
    {
        mission.primary[taskIndex].isCompleted = !mission.primary[taskIndex].isCompleted;
        changed = true;
    }
    else
    {
        int secondaryIndex = taskIndex - static_cast<int>(mission.primary.size());
        if(secondaryIndex < mission.secondary.size())
        {
            mission.secondary[secondaryIndex].isCompleted = !mission.secondary[secondaryIndex].isCompleted;
            changed = true;
        }
    }

    if(!changed)
    {
        return;
    }


    if(areAllTasksCompleted(mission))
    {
        mission.isCompleted = true;
        mission.isSuccess = true;
        mission.isActive = false;
    }

    sourceModel_->updateMission(sourceRow, mission);

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

void MissionManager::toggleMissionStatus(int index)
{
    if(!isValidIndex(index))
    {
        return;
    }

    QModelIndex sourceIndex{filterModel_->mapToSource(filterModel_->index(index, 0))};
    int sourceRow{sourceIndex.row()};

    Mission mission{sourceModel_->getMission(sourceRow)};

    mission.isCompleted =  !mission.isCompleted;
    mission.isSuccess = false;
    mission.isActive = false;

    sourceModel_->updateMission(sourceRow, mission);
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

void MissionManager::addMission(QVariantMap missionMap)
{
    Mission m;
    m.title = missionMap.value("title").toString().toStdString();
    m.category = missionMap.value("category").toString().toStdString();

    sourceModel_->addMission(m);
    saveMissions();
    emit currentIndexChanged();
}

void MissionManager::editMission(int index, QVariantMap updatedMission)
{
    if(!isValidIndex(index))
    {
        return;
    }

    QModelIndex sourceIndex{filterModel_->mapToSource(filterModel_->index(index, 0))};
    int sourceRow{sourceIndex.row()};

    Mission existingMission{sourceModel_->getMission(sourceRow)};

    existingMission.title = updatedMission.value("title").toString().toStdString();
    existingMission.category = updatedMission.value("category").toString().toStdString();

    sourceModel_->updateMission(sourceRow, existingMission);
    saveMissions();

    emit currentIndexChanged();
}

void MissionManager::resetToDefault()
{
    QString writablePath{getWritablePath()};
    const QString resourcePath{":/qt/qml/MissionsLog/missions.json"};

    if (QFile::exists(writablePath))
    {
        if (!QFile::remove(writablePath))
        {
            qWarning() << "Failed to remove existing writable file during reset!";
            return;
        }
    }

    if (!QFile::copy(resourcePath, writablePath))
    {
        qWarning() << "Failed to copy template file during reset!";
        return;
    }

    QFile::setPermissions(writablePath, QFile::ReadOwner | QFile::WriteOwner);

    loadMissions(writablePath);
}


void MissionManager::saveMissions()
{
    QJsonObject categories;
    QJsonArray main, side;

    for (const auto &mission : sourceModel_->getAllMissions())
    {
        QJsonObject missionObj;
        missionObj["id"] = QString::fromStdString(mission.id);
        missionObj["title"] = QString::fromStdString(mission.title);
        missionObj["isActive"] = mission.isActive;
        missionObj["isCompleted"] = mission.isCompleted;
        missionObj["isSuccess"] = mission.isSuccess;

        QJsonArray primary;

        for(const auto &temp : mission.primary)
        {
            primary.append(taskToJson(temp));
        }

        missionObj["primary"] = primary;

        if(!mission.secondary.empty())
        {
            QJsonArray secondary;
            for(const auto &temp : mission.secondary)
            {
                secondary.append(taskToJson(temp));
            }
            missionObj["secondary"] = secondary;
        }

        if(mission.category == "side")
        {
            side.append(missionObj);
        }
        else
        {
            main.append(missionObj);
        }
    }

    categories["main"] = main;
    categories["side"] = side;

    QJsonObject rootObj{{"mission", categories}};

    QString path{getWritablePath()};
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

bool MissionManager::areAllTasksCompleted(const Mission  &mission) const
{
    auto checkList = [](const std::vector<Task> &list)
    {
        return std::ranges::all_of(list, [](const Task &item){
            return item.isCompleted;
        });
    };

    return checkList(mission.primary) && checkList(mission.secondary);
}

int MissionManager::sourceIndexFromMissionId(const QString &missionId) const
{
    const auto missions{sourceModel_->getAllMissions()};
    std::string idToFind = missionId.toStdString();

    auto it = std::ranges::find_if(missions, [&idToFind](const Mission& mission) {
        return mission.id == idToFind;
    });

    if (it != missions.end()) {
        return static_cast<int>(std::distance(missions.begin(), it));
    }

    return -1;
}