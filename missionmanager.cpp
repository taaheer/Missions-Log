#include "missionmanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

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
    if(!index.isValid() || index.row() < 0 || index.row() >= missions_.size())
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
    if(index < 0 || index >= missions_.size())
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
    if(currentIndex_ == index || index < 0 || index >= missions_.size())
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

