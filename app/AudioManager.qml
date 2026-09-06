// All game audio. Sounds are original, synthesized by scripts/gen-audio.py and shipped as WAV
// resources. Desktop: Clayground.Sound (Qt Multimedia), music loops re-triggered by a Timer.
// WebAssembly: the WebAudio bridge (browser AudioContext) - Clayground.Sound stalls the page there.
import QtQuick
import Clayground.Sound

Item {
    id: audio
    property bool soundOn: true
    property real sfxVolume: 0.8
    property real musicVolume: 0.5
    property string currentMusic: ""        // outdoor | indoor | end | ""
    property bool musicPaused: false

    readonly property var _names: ["jump", "land", "step_grass", "step_concrete", "step_metal", "collect_star", "collect_pencil",
                                   "collect_memory", "switch_char", "mechanism", "gate_open", "courage_lose", "courage_out", "checkpoint",
                                   "bell", "push", "metal", "ball_bounce", "level_complete", "ui_move", "ui_accept", "reveal", "whoosh", "grab"]
    readonly property var _musicLength: ({ outdoor: 24000, indoor: 24000, end: 6000 })
    property var _sounds: ({})
    property var _music: ({})
    property var _lastPlayed: ({})
    readonly property var _minGap: ({ step_grass: 0.22, step_concrete: 0.22, step_metal: 0.22, land: 0.1, push: 0.35, metal: 0.2, ball_bounce: 0.3 })

    Component { id: soundComp; Sound { volume: audio.sfxVolume; lazyLoading: false } }
    Component { id: musicComp; Sound { volume: audio.musicVolume; lazyLoading: true } }
    WebAudio { id: web }
    readonly property bool useWeb: web.available

    readonly property bool audioEnabled: Qt.application.arguments.indexOf("--no-audio") < 0
    Component.onCompleted: {
        console.log("AudioManager: audio", audioEnabled ? "on" : "off", useWeb ? "(browser AudioContext)" : "(Clayground.Sound)")
        if (!audioEnabled) { soundOn = false; return }
        if (useWeb) {
            for (const n of _names) web.load(n, Qt.resolvedUrl("assets/audio/" + n + ".wav"))
            for (const n in _musicLength) web.load("music_" + n, Qt.resolvedUrl("assets/audio/music_" + n + ".wav"))
            return
        }
        const map = {}
        for (const n of _names) map[n] = soundComp.createObject(audio, { source: Qt.resolvedUrl("assets/audio/" + n + ".wav") })
        _sounds = map
        const mm = {}
        for (const n in _musicLength) mm[n] = musicComp.createObject(audio, { source: Qt.resolvedUrl("assets/audio/music_" + n + ".wav") })
        _music = mm
    }

    function play(name, volumeScale) {
        if (!soundOn || !audioEnabled) return
        const now = Date.now() / 1000
        const gap = _minGap[name] || 0
        if (gap > 0 && _lastPlayed[name] && now - _lastPlayed[name] < gap) return
        _lastPlayed[name] = now
        const vol = sfxVolume * (volumeScale === undefined ? 1 : volumeScale)
        if (useWeb) { web.play(name, vol); return }
        const s = _sounds[name]
        if (!s) return
        s.volume = vol
        s.play()
    }
    function footstep(surface) {
        if (surface === "metal" || surface === "moving") play("step_metal", 0.5)
        else if (surface === "grass" || surface === "rubber") play("step_grass", 0.5)
        else play("step_concrete", 0.5)
    }

    Timer {
        id: musicLoop
        repeat: true; running: false
        onTriggered: { const m = audio._music[audio.currentMusic]; if (m && audio.soundOn) m.play() }
    }
    function playMusic(name) {
        if (!audioEnabled) return
        if (name === currentMusic && (musicLoop.running || (useWeb && !musicPaused))) return
        stopMusic()
        currentMusic = name
        musicPaused = false
        if (useWeb) { if (soundOn) web.playMusic("music_" + name, musicVolume, name !== "end"); return }
        const m = _music[name]
        if (!m) return
        m.volume = musicVolume
        if (soundOn) m.play()
        musicLoop.interval = (_musicLength[name] || 20000) - 150
        musicLoop.restart()
    }
    function stopMusic() { musicLoop.stop(); if (useWeb) web.stopMusic(); else for (const n in _music) _music[n].stop(); musicPaused = false }
    function pauseMusic() { if (!currentMusic) return; musicLoop.stop(); if (useWeb) web.pauseMusic(); else { const m = _music[currentMusic]; if (m) m.stop() } musicPaused = true }
    function resumeMusic() { if (!currentMusic || !musicPaused) return; if (useWeb) { if (soundOn) web.resumeMusic() } else { const m = _music[currentMusic]; if (m && soundOn) { m.play(); musicLoop.restart() } } musicPaused = false }
    onMusicVolumeChanged: { if (useWeb) web.setMusicVolume(musicVolume); else for (const n in _music) _music[n].volume = musicVolume }
    onSoundOnChanged: if (!soundOn) stopMusic()
}
