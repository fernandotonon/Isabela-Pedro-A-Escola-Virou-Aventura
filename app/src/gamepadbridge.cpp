// Isabela & Pedro: A Escola Virou Aventura - MIT License, see LICENSE
#include "gamepadbridge.h"

#include <QStringList>
#include <cmath>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <cstdlib>

// Returns "connected;name;axisX;axisY;buttonMask" for the first connected pad, "" when none.
// The W3C standard mapping is assumed (it is what every mainstream pad reports in browsers);
// pads with a non-standard mapping still yield axes 0/1 and the first buttons.
// clang-format off
EM_JS(char *, escola_gamepad_poll, (), {
    try {
        const pads = (navigator.getGamepads && navigator.getGamepads()) || [];
        let pad = null;
        for (const p of pads) { if (p && p.connected) { pad = p; break; } }
        if (!pad) return 0;
        let mask = 0;
        for (let i = 0; i < Math.min(pad.buttons.length, 17); ++i) {
            const b = pad.buttons[i];
            if (b && (b.pressed || b.value > 0.5)) mask |= (1 << i);
        }
        let ax = pad.axes.length > 0 ? pad.axes[0] : 0;
        let ay = pad.axes.length > 1 ? pad.axes[1] : 0;
        const s = "1;" + (pad.id || "gamepad").replace(/;/g, ",") + ";" + ax + ";" + ay + ";" + mask;
        const n = lengthBytesUTF8(s) + 1;
        const p = _malloc(n);
        stringToUTF8(s, p, n);
        return p;
    } catch (e) { return 0; }
});
// clang-format on
#endif

GamepadBridge::GamepadBridge(QObject *parent) : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout, this, &GamepadBridge::poll);
#ifdef __EMSCRIPTEN__
    m_timer.start(1000 / m_pollHz);
#endif
}

bool GamepadBridge::available() const
{
#ifdef __EMSCRIPTEN__
    return true;
#else
    return false;
#endif
}

void GamepadBridge::setPollHz(int hz)
{
    hz = qBound(10, hz, 240);
    if (hz == m_pollHz)
        return;
    m_pollHz = hz;
    if (m_timer.isActive())
        m_timer.start(1000 / m_pollHz);
    emit pollHzChanged();
}

void GamepadBridge::setDeadZone(double dz)
{
    dz = qBound(0.0, dz, 0.9);
    if (qFuzzyCompare(dz, m_deadZone))
        return;
    m_deadZone = dz;
    emit deadZoneChanged();
}

void GamepadBridge::injectState(bool connected, double axisX, double axisY, int buttonMask)
{
    apply(connected, QStringLiteral("synthetic"), axisX, axisY, static_cast<quint32>(buttonMask));
}

void GamepadBridge::apply(bool connected, const QString &name, double ax, double ay, quint32 buttons)
{
    auto dead = [this](double v) {
        if (std::fabs(v) < m_deadZone)
            return 0.0;
        const double sign = v < 0 ? -1.0 : 1.0;
        return sign * (std::fabs(v) - m_deadZone) / (1.0 - m_deadZone);
    };
    ax = dead(ax);
    ay = dead(ay);
    // d-pad doubles as the axis so menu navigation and walking work on every pad
    if (buttons & (1u << 14)) ax = -1;
    if (buttons & (1u << 15)) ax = 1;
    if (buttons & (1u << 12)) ay = -1;
    if (buttons & (1u << 13)) ay = 1;
    const bool changed = connected != m_connected || name != m_name || buttons != m_buttons
                         || !qFuzzyCompare(ax + 1.0, m_axisX + 1.0) || !qFuzzyCompare(ay + 1.0, m_axisY + 1.0);
    m_connected = connected;
    m_name = name;
    m_axisX = ax;
    m_axisY = ay;
    m_buttons = buttons;
    if (changed)
        emit stateChanged();
}

void GamepadBridge::poll()
{
#ifdef __EMSCRIPTEN__
    char *raw = escola_gamepad_poll();
    if (!raw) {
        apply(false, QString(), 0, 0, 0);
        return;
    }
    const QString s = QString::fromUtf8(raw);
    std::free(raw);
    const QStringList parts = s.split(QLatin1Char(';'));
    if (parts.size() < 5) {
        apply(false, QString(), 0, 0, 0);
        return;
    }
    apply(true, parts[1], parts[2].toDouble(), parts[3].toDouble(), parts[4].toUInt());
#endif
}
