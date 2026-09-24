cmake_minimum_required(VERSION 3.16)

if(NOT DEFINED APP_VERSION)
    set(APP_VERSION "0.0.0")
endif()

project(MissionsLog VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

set(QWINDOWKIT_BUILD_WIDGETS OFF CACHE BOOL "" FORCE)
set(QWINDOWKIT_BUILD_QUICK ON CACHE BOOL "" FORCE)

if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/external/qwindowkit/CMakeLists.txt")
    add_subdirectory(external/qwindowkit)
endif()

set(APP_ICONS "")
if(APPLE)
    list(APPEND APP_ICONS "${CMAKE_CURRENT_SOURCE_DIR}/app.icns")
elseif(WIN32)
    list(APPEND APP_ICONS "${CMAKE_CURRENT_SOURCE_DIR}/app.rc")
endif()


qt_add_executable(appMissionsLog
    main.cpp
    ${APP_ICONS}
)

set_source_files_properties(Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(appMissionsLog
    URI MissionsLog

    QML_FILES
    Main.qml
    Theme.qml
    DecoderText.qml
    Icon.qml
    RepeatingCharacter.qml
    AnimatedBullets.qml
    WindowBarButton.qml
    HexagonPanel.qml
    LeftLayout.qml
    RightLayout.qml
    CustomScrollBar.qml
    CustomButton.qml
    MissionPopup.qml
    SwipeButton.qml
    CustomTextField.qml
    CustomMenu.qml
    CustomMenuItem.qml
    CustomDialog.qml

    SOURCES
    missionmanager.h missionmanager.cpp
    missionmodel.h missionmodel.cpp
    missionfilter.h missionfilter.cpp
    mission.h

    RESOURCES
    missions.json
    app.png
)



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMissionsLog PROPERTIES
    OUTPUT_NAME "MissionsLog"
    MACOSX_BUNDLE_GUI_IDENTIFIER com.taaheer.missionslog
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_ICON_FILE app.icns
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMissionsLog
    PRIVATE
    Qt6::Quick
    QWindowKit::Quick
)

target_compile_definitions(appMissionsLog PRIVATE
    APP_VERSION="${PROJECT_VERSION}"
)

install(TARGETS appMissionsLog
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET appMissionsLog
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
)
install(SCRIPT ${deploy_script})

if(APPLE)
    set_source_files_properties(app.icns PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources
    )
endif()
