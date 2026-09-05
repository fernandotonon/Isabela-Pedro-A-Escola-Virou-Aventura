// Save system: one JSON profile in SaveStore (browser localStorage on WebAssembly, QSettings on
// desktop). Keeps the current checkpoint and its world snapshot, unlocked levels, collectibles,
// the Family Memory, best time, volumes, language and control preferences.
import QtQuick

Item {
    id: save
    readonly property string profileKey: "profile.v1"
    readonly property string settingsKey: "settings.v1"
    property var profile: null
    property var settings: ({ musicVolume: 0.5, sfxVolume: 0.8, language: "pt_BR", quality: 1, keys: null })
    readonly property bool hasProgress: profile !== null && profile.checkpoint !== undefined
    readonly property string backend: store.backend

    SaveStore { id: store }

    function load() {
        try { const p = store.get(profileKey, ""); profile = p ? JSON.parse(p) : null } catch (e) { console.warn("SaveSystem: bad profile, ignoring", e); profile = null }
        try { const s = store.get(settingsKey, ""); if (s) settings = Object.assign({}, settings, JSON.parse(s)) } catch (e) { console.warn("SaveSystem: bad settings", e) }
    }
    function writeProfile(p) { profile = p; store.set(profileKey, JSON.stringify(p)) }
    function writeSettings(s) { settings = Object.assign({}, settings, s); store.set(settingsKey, JSON.stringify(settings)) }
    function clearProgress() { store.remove(profileKey); profile = null }

    // what a checkpoint preserves
    function saveCheckpoint(data) {
        // data: { level, checkpoint, x, y, activeCharacter, courage, world (director snapshot), collected, memoryFound, elapsed }
        const p = Object.assign({}, profile || {}, data, { savedAt: new Date().toISOString(), unlockedLevels: (profile && profile.unlockedLevels) || ["caminho_para_a_sala"] })
        writeProfile(p)
    }
    function recordCompletion(elapsedSeconds, stars, pencils, memoryFound) {
        const p = Object.assign({}, profile || {})
        p.bestTime = p.bestTime === undefined ? elapsedSeconds : Math.min(p.bestTime, elapsedSeconds)
        p.bestStars = Math.max(p.bestStars || 0, stars)
        p.bestPencils = Math.max(p.bestPencils || 0, pencils)
        p.memoryFound = (p.memoryFound === true) || memoryFound
        p.completed = true
        writeProfile(p)
    }
}
