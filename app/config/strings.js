// UI strings. English is the source text and the fallback: a missing translation shows in English.
// Language files live in config/i18n/<code>.js. Which language is used (first match wins):
//   1. the player's choice in the game (Settings -> Language), unless "Auto"
//   2. the QtMesh Games launcher: QTMESH_LANG (desktop) or ?qtmesh_lang= (web); --lang= for testing
//   3. the device / OS language
//   4. English
// Codes match Scrapfall and the launcher (pt_BR, pt-BR and pt all mean Brazilian Portuguese).
// Names in LANGS are each language's own name and are never translated.
// Translations were machine-written and should be reviewed by native speakers.
.pragma library
.import "i18n/pt_br.js" as I18nPtBr
.import "i18n/de.js" as I18nDe
.import "i18n/ru.js" as I18nRu
.import "i18n/fr.js" as I18nFr
.import "i18n/pl.js" as I18nPl
.import "i18n/tr.js" as I18nTr
.import "i18n/es.js" as I18nEs
.import "i18n/it.js" as I18nIt

var en = {
    "game.title": "Isabela & Pedro",
    "game.subtitle": "School Turned Adventure",
    "game.school": "Horizonte School",
    "level.caminho.name": "The Way to the Classroom",
    "section.pracinha": "The square",
    "section.jardim": "The garden",
    "section.playground": "The playground",
    "section.patio": "The games yard",
    "section.quadra": "The covered court",
    "section.corredor": "The giant corridor",
    "menu.newGame": "New game", "menu.continue": "Continue", "menu.controls": "Controls", "menu.volume": "Settings",
    "menu.music": "Music", "menu.effects": "Effects", "menu.language": "Language", "menu.resume": "Resume",
    "menu.restartCheckpoint": "Restart at checkpoint", "menu.quitToTitle": "Back to title", "menu.paused": "Paused",
    "menu.back": "Back", "menu.gallery": "Gallery", "menu.loading": "Loading imagination...",
    "menu.pressStart": "Press Space or Start", "menu.nextLevel": "Next level: Coming soon", "menu.playAgain": "Play again",
    "menu.confirmNew": "Starting a new game erases the saved progress. Continue?", "menu.yes": "Yes", "menu.no": "No",
    "controls.title": "Controls", "controls.move": "Move", "controls.jump": "Jump (hold for a higher jump)",
    "controls.interact": "Interact", "controls.switch": "Switch character", "controls.ability": "Special ability",
    "controls.crouch": "Crouch / crawl under (Pedro)", "controls.pause": "Pause", "controls.keyboard": "Keyboard",
    "controls.gamepad": "Gamepad", "controls.gamepadNote": "Gamepads work in the browser; on desktop use the keyboard.",
    "controls.space": "Space",
    "hud.courage": "Courage", "hud.stars": "Stars", "hud.pencils": "Pencils", "hud.interact": "Interact",
    "hud.needBoth": "Both siblings need to be here", "hud.checkpoint": "Checkpoint!", "hud.courageLost": "Oops! Courage -1",
    "hud.courageOut": "Deep breath... back to the checkpoint", "hud.memoryFound": "Family Memory found!",
    "hud.pencilFound": "Coloured pencil!", "hud.gateOpen": "The gate opened!", "hud.mechanism": "Mechanism activated",
    "hud.revealed": "Isabela's notebook revealed a path!", "hud.curiosity": "Pedro's curiosity found something!",
    "hud.nothingHere": "Nothing here... yet.", "hud.pushTooHeavy": "Too heavy for Pedro. Call Isabela!",
    "hud.tooHigh": "Too high for Pedro. Isabela can reach it!", "hud.tooSmall": "Only Pedro fits through here!",
    "hint.move": "Use the ARROWS or A/D to walk. Keep walking to run!",
    "hint.jump": "Press SPACE to jump. Hold it to jump higher.",
    "hint.stars": "Collect the Courage Stars!",
    "hint.switch": "Press Q or TAB to switch between Isabela and Pedro.",
    "hint.abilities": "Isabela jumps high and grabs ledges. Pedro is fast and crawls under things.",
    "hint.crawl": "As Pedro, hold ↓ to crouch and crawl under.",
    "hint.move.touch": "Drag your finger on the left half of the screen to walk.",
    "hint.jump.touch": "Tap ▲ to jump. Hold for a higher jump.",
    "hint.switch.touch": "Tap the other sibling's card to switch characters.",
    "hint.crawl.touch": "As Pedro, drag down to crouch and crawl under.",
    "hint.ledge.touch": "As Isabela, jump towards a ledge to grab it. Drag up to climb.",
    "hint.lever.touch": "Tap E next to the lever.",
    "hint.notebook.touch": "As Isabela, tap ✦ to use the notebook and reveal clues.",
    "touch.jump": "jump", "touch.ability": "ability", "touch.interact": "use", "touch.switch": "tap to switch",
    "hint.ledge": "As Isabela, jump towards a ledge to grab it. ↑ to climb.",
    "hint.button": "Step on the button to activate it.",
    "hint.lever": "Press E next to the lever.",
    "hint.push": "Walk into the box to push it.",
    "hint.pushmedium": "The bench is heavy: only Isabela can push it.",
    "hint.moving": "Watch the platform's rhythm before jumping.",
    "hint.plates": "Isabela and Pedro must stand together on the marks.",
    "hint.notebook": "As Isabela, press SHIFT to use the notebook and reveal clues.",
    "hint.notebook2": "A path seems to be missing here... Isabela's notebook may help.",
    "hint.playground": "The playground is huge! Isabela climbs; Pedro goes through the tunnel.",
    "hint.patio": "Hop between the benches and tables.",
    "hint.ball": "Watch the ball! It only startles, but it costs Courage.",
    "hint.pushbutton": "Push the lunchbox onto the button.",
    "hint.quadra": "Take the ball to the goal. Pedro fits under the stands.",
    "hint.corridor": "The corridor grew! Jump over the books and mind the planes.",
    "hint.desk": "Push the desk to the window to reach the ledge.",
    "story.bell": "🔔 The bell rang! The siblings' imagination turns the way into an adventure...",
    "story.gate_far": "The gate seems farther and farther away...",
    "story.gate_open": "Together, Isabela and Pedro open the gate of Horizonte School!",
    "story.corridor_grows": "The corridor grows like a maze. The clock is ticking!",
    "story.finished": "They made it! The world goes back to normal and the siblings celebrate.",
    "story.intro": "Isabela and Pedro wait in the square in front of the school.",
    "end.title": "Level complete!", "end.stars": "Courage Stars", "end.pencils": "Coloured pencils", "end.memory": "Family Memory",
    "end.found": "found", "end.notFound": "still hidden", "end.time": "Time", "end.best": "Best time",
    "gallery.title": "Gallery", "gallery.locked": "Find the Family Memory in the square to unlock.",
    "gallery.memory1.title": "A day in the square",
    "gallery.memory1.text": "A drawing of the whole family on the park bench, with ice cream and a paper plane.",
    "char.isabela": "Isabela", "char.pedro": "Pedro", "dev.title": "Development tools"
}

var pt_BR = I18nPtBr.strings
var de = I18nDe.strings
var ru = I18nRu.strings
var fr = I18nFr.strings
var pl = I18nPl.strings
var tr_ = I18nTr.strings
var es = I18nEs.strings
var it = I18nIt.strings

var ORDER = ["en", "pt_BR", "de", "ru", "fr", "pl", "tr", "es", "it"]
var LANGS = {
    en: "English", pt_BR: "Português (Brasil)", de: "Deutsch", ru: "Русский",
    fr: "Français", pl: "Polski", tr: "Türkçe", es: "Español", it: "Italiano"
}
var languages = { en: en, pt_BR: pt_BR, de: de, ru: ru, fr: fr, pl: pl, tr: tr_, es: es, it: it }

// "pt-br", "PT_br", "pt" -> "pt_BR" (a bare language matches the first supported variant); "" if unsupported.
function matchCode(raw) {
    if (raw === undefined || raw === null) return ""
    var r = String(raw).trim().replace(/-/g, "_").split(".")[0].split("@")[0]
    if (!r) return ""
    var low = r.toLowerCase()
    var i
    for (i = 0; i < ORDER.length; ++i) if (ORDER[i].toLowerCase() === low) return ORDER[i]
    var lang = low.split("_")[0]
    for (i = 0; i < ORDER.length; ++i) if (ORDER[i].toLowerCase().split("_")[0] === lang) return ORDER[i]
    return ""
}

// Stored setting: a code from ORDER, or "" for Auto (empty / invalid).
function userChoice(stored) {
    if (stored === undefined || stored === null || stored === "") return ""
    return matchCode(stored)
}

function resolve(user, launcher, os) {
    var u = userChoice(user)
    if (u) return u
    var l = matchCode(launcher)
    if (l) return l
    var o = matchCode(os)
    if (o) return o
    return "en"
}

// Next setting when the language row is stepped. "" is Auto, then ORDER, wrapping around.
function cycleChoice(stored, delta) {
    var choices = [""].concat(ORDER)
    var i = choices.indexOf(userChoice(stored))
    if (i < 0) i = 0
    var step = delta < 0 ? -1 : 1
    return choices[(i + step + choices.length) % choices.length]
}

function has(key) { return en[key] !== undefined }

function tr(key, lang) {
    var code = (lang === undefined || lang === null || lang === "") ? "en" : (matchCode(lang) || "en")
    var table = languages[code] || en
    if (table[key] !== undefined) return table[key]
    if (en[key] !== undefined) return en[key]
    return key
}
