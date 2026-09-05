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
file(GLOB_RECURSE ESCOLA_RUNTIME_ASSETS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/assets/runtime/*" "${CMAKE_SOURCE_DIR}/assets/sprites/*")
file(GLOB ESCOLA_AUDIO_ASSETS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/assets/audio/*.wav")
set(ESCOLA_RES_FILES ${ESCOLA_AUDIO_ASSETS})
if(NOT EMSCRIPTEN)
    list(APPEND ESCOLA_RES_FILES ${ESCOLA_RUNTIME_ASSETS})
endif()
list(FILTER ESCOLA_RES_FILES EXCLUDE REGEX "\\.DS_Store$")
foreach(_f IN LISTS ESCOLA_RES_FILES)
    file(RELATIVE_PATH _rel "${CMAKE_SOURCE_DIR}" "${_f}")
    set_source_files_properties("${_f}" PROPERTIES QT_RESOURCE_ALIAS "${_rel}")
endforeach()

clay_app(escola_aventura
    VERSION 0.1.0

    SOURCES
        src/savestore.h src/savestore.cpp
        src/gamepadbridge.h src/gamepadbridge.cpp

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

# The QML type registration generated for SaveStore/GamepadBridge includes the headers by bare
# name (<savestore.h>), so the C++ sources' directory must be on the include path.
target_include_directories(escola_aventura PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
