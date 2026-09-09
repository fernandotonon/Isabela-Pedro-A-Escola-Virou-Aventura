# Application target, declared through Clayground's clay_app() helper (entry point: Main.qml).
include(clayapp)

# Development tools (collider view, teleports, mechanism toggles...) are compiled in only when
# this is ON. Default: ON for desktop builds, OFF for WebAssembly (the published build).
if(EMSCRIPTEN)
    option(ESCOLA_DEV_TOOLS "Compile the in-game development tools" OFF)
else()
    option(ESCOLA_DEV_TOOLS "Compile the in-game development tools" ON)
endif()
if(ESCOLA_DEV_TOOLS)
    set(ESCOLA_DEV_TOOLS_JS "true")
    set(ESCOLA_DEV_QML DevTools.qml)
else()
    set(ESCOLA_DEV_TOOLS_JS "false")
    set(ESCOLA_DEV_QML "")
endif()
configure_file(config/build.js.in "${CMAKE_CURRENT_BINARY_DIR}/config/build.js" @ONLY)
set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/config/build.js" PROPERTIES QT_RESOURCE_ALIAS "config/build.js")

# Runtime assets (balsam output under assets/runtime, sprite sheets, audio) live outside app/;
# each file gets an alias that keeps the "assets/..." path Qt.resolvedUrl() expects.
#  * desktop: compiled into the binary as resources (qrc:/assets/...)
#  * WebAssembly: 3D/sprite assets are NOT embedded - scripts/build-wasm.sh ships them as files
#    that Qt's loader preloads into the in-memory filesystem (/game/assets/...).
#  * Android: embedded too, but from a shrunk copy (textures -> JPEG, same as the web deploy) so the
#    APK stays small; the copy is made at configure time under the build directory.
set(ESCOLA_ASSET_ROOT "${CMAKE_SOURCE_DIR}")
if(ANDROID)
    set(ESCOLA_ASSET_ROOT "${CMAKE_BINARY_DIR}/android-assets")
    if(NOT EXISTS "${ESCOLA_ASSET_ROOT}/assets/.optimized")
        message(STATUS "Android: preparing the shrunk asset copy in ${ESCOLA_ASSET_ROOT}")
        file(REMOVE_RECURSE "${ESCOLA_ASSET_ROOT}")
        file(COPY "${CMAKE_SOURCE_DIR}/assets/runtime" "${CMAKE_SOURCE_DIR}/assets/sprites" DESTINATION "${ESCOLA_ASSET_ROOT}/assets")
        execute_process(COMMAND python3 "${CMAKE_SOURCE_DIR}/scripts/web-optimize-assets.py" "${ESCOLA_ASSET_ROOT}/assets" RESULT_VARIABLE _opt)
        if(NOT _opt EQUAL 0)
            message(FATAL_ERROR "scripts/web-optimize-assets.py failed (needs python3 + Pillow)")
        endif()
        file(GLOB_RECURSE _gz "${ESCOLA_ASSET_ROOT}/assets/*.mesh.gz")
        if(_gz)
            file(REMOVE ${_gz})
        endif()
        file(WRITE "${ESCOLA_ASSET_ROOT}/assets/.optimized" "1")
    endif()
endif()
file(GLOB_RECURSE ESCOLA_RUNTIME_ASSETS CONFIGURE_DEPENDS "${ESCOLA_ASSET_ROOT}/assets/runtime/*" "${ESCOLA_ASSET_ROOT}/assets/sprites/*")
file(GLOB ESCOLA_AUDIO_ASSETS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/assets/audio/*.wav")
set(ESCOLA_RES_FILES ${ESCOLA_AUDIO_ASSETS})
if(NOT EMSCRIPTEN)
    list(APPEND ESCOLA_RES_FILES ${ESCOLA_RUNTIME_ASSETS})
endif()
list(FILTER ESCOLA_RES_FILES EXCLUDE REGEX "\\.DS_Store$|\\.optimized$")
foreach(_f IN LISTS ESCOLA_RES_FILES)
    if(_f MATCHES "^${ESCOLA_ASSET_ROOT}/")
        file(RELATIVE_PATH _rel "${ESCOLA_ASSET_ROOT}" "${_f}")
    else()
        file(RELATIVE_PATH _rel "${CMAKE_SOURCE_DIR}" "${_f}")
    endif()
    set_source_files_properties("${_f}" PROPERTIES QT_RESOURCE_ALIAS "${_rel}")
endforeach()

clay_app(escola_aventura
    VERSION 0.1.0

    SOURCES
        src/savestore.h src/savestore.cpp
        src/gamepadbridge.h src/gamepadbridge.cpp
        src/webaudio.h src/webaudio.cpp

    LINK_LIBS
        Qt::Core
        Qt::Qml
        Qt::Quick
        Qt::Quick3D
        Qt::Quick3DHelpers
        Qt::Quick3DAssetUtils
        Qt::QuickTimeline
        Qt::Multimedia

    QML_FILES
        Main.qml
        QmlModules.qml
        EscolaGame.qml
        GameWorld.qml
        SideCamera.qml
        InputManager.qml
        Character.qml
        CharacterVisual.qml
        Sprite3D.qml
        PropVisual.qml
        Prop.qml
        GroundSlab.qml
        MovingPlatform.qml
        Pushable.qml
        Switch.qml
        Gate.qml
        Collectible.qml
        Checkpoint.qml
        Hazard.qml
        TriggerZone.qml
        FinalDoor.qml
        LevelDirector.qml
        Effects.qml
        ScreenFade.qml
        AudioManager.qml
        SaveSystem.qml
        Hud.qml
        TouchControls.qml
        MenuOverlay.qml
        ${ESCOLA_DEV_QML}
        scripts/Physics.js
        scripts/StateMachine.js
        scripts/CharacterMotion.js
        scripts/CompanionAI.js
        scripts/Courage.js
        scripts/LevelCheck.js
        scripts/PlaceholderShapes.js
        scripts/Walkthrough.js
        config/walkthrough.js
        config/tuning.js
        config/level.js
        config/strings.js
        config/assets.js
        "${CMAKE_CURRENT_BINARY_DIR}/config/build.js"

    RES_FILES
        ${ESCOLA_RES_FILES}
)

if(EMSCRIPTEN)
    # Qt Quick 3D plus the preloaded assets need more than Clayground's 64 MB default heap;
    # it still grows on demand (ALLOW_MEMORY_GROWTH).
    set_target_properties(escola_aventura PROPERTIES QT_WASM_INITIAL_MEMORY "256MB")
endif()

if(ANDROID)
    # Clayground's clay_app writes an old-style manifest (no android:exported, gradle 7); replace it with
    # the Qt 6.11 template plus the game's settings, and ship our launcher icons.
    # version code and name come from the git tag when there is one (v0.1.3 -> code 103, name 0.1.3), so a
    # newer APK installs over an older one instead of being refused as a downgrade
    set(ESCOLA_ANDROID_VERSION_NAME "${PROJECT_VERSION}")
    execute_process(COMMAND git describe --tags --abbrev=0 WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                    OUTPUT_VARIABLE ESCOLA_GIT_TAG OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(ESCOLA_GIT_TAG MATCHES "^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
        set(ESCOLA_ANDROID_VERSION_NAME "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")
        math(EXPR ESCOLA_ANDROID_VERSION_CODE "${CMAKE_MATCH_1} * 10000 + ${CMAKE_MATCH_2} * 100 + ${CMAKE_MATCH_3}")
    else()
        set(ESCOLA_ANDROID_VERSION_CODE 1)
    endif()
    message(STATUS "Android package version ${ESCOLA_ANDROID_VERSION_NAME} (code ${ESCOLA_ANDROID_VERSION_CODE})")
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml.in" "${CMAKE_CURRENT_BINARY_DIR}/android/AndroidManifest.xml" @ONLY)
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/android/res" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/android")
    file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/android/gradle.properties")
    set_target_properties(escola_aventura PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/android"
        QT_ANDROID_MIN_SDK_VERSION 28
        QT_ANDROID_TARGET_SDK_VERSION 36
        QT_ANDROID_COMPILE_SDK_VERSION 36        # Qt 6.11's androidx dependencies need compileSdk 36
        QT_ANDROID_VERSION_NAME "${ESCOLA_ANDROID_VERSION_NAME}"
        QT_ANDROID_VERSION_CODE ${ESCOLA_ANDROID_VERSION_CODE}
        QT_ANDROID_APP_NAME "Isabela & Pedro"
        QT_ANDROID_APP_ICON "@drawable/icon")
endif()

# The QML type registration generated for SaveStore/GamepadBridge includes the headers by bare
# name (<savestore.h>), so the C++ sources' directory must be on the include path.
target_include_directories(escola_aventura PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
