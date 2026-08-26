cmake_minimum_required(VERSION 3.16)

project(MissionsLog VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

set(QWINDOWKIT_BUILD_WIDGETS OFF CACHE BOOL "" FORCE)
set(QWINDOWKIT_BUILD_QUICK ON CACHE BOOL "" FORCE)

if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/external/qwindowkit/CMakeLists.txt")
    add_subdirectory(external/qwindowkit)
endif()

qt_add_executable(appMissionsLog
    main.cpp
)

set_source_files_properties(Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(appMissionsLog
    URI MissionsLog
    QML_FILES
        Main.qml
        QML_FILES Theme.qml
        QML_FILES DecoderText.qml
        QML_FILES Icon.qml
        QML_FILES RepeatingCharacter.qml
        QML_FILES AnimatedBullets.qml
        QML_FILES WindowBarButton.qml
        QML_FILES HexagonPanel.qml
        QML_FILES LeftLayout.qml
        QML_FILES RightLayout.qml
        SOURCES
        SOURCES missionmanager.h missionmanager.cpp
        RESOURCES missions.json
        QML_FILES CustomScrollBar.qml
        QML_FILES CustomButton.qml
)



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMissionsLog PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.taaheer.missionslog
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMissionsLog
    PRIVATE
        Qt6::Quick
        QWindowKit::Quick
)

install(TARGETS appMissionsLog
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
