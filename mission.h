#ifndef MISSION_H
#define MISSION_H

#include <string>
#include <vector>

struct Task {
    std::string name;
    std::string detail;
    bool isCompleted = false;
};

struct Mission {
    std::string id;
    std::string title;
    std::string category;
    bool isActive = false;
    bool isCompleted = false;
    bool isSuccess = false;

    std::vector<Task> primary;
    std::vector<Task> secondary;
};

#endif // MISSION_H
