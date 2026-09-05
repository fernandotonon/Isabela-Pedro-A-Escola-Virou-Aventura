// Isabela & Pedro: A Escola Virou Aventura - MIT License, see LICENSE
#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

/// Physical gamepad input. Qt 6 ships no gamepad module, so:
///  * WebAssembly: polls the browser Gamepad API (navigator.getGamepads) with the W3C
///    "standard" mapping - works with Xbox/PlayStation/Switch Pro pads in Chrome/Firefox/Safari.
///  * desktop: reports no gamepad (connected stays false); keyboard is the desktop input.
/// Axes are -1..1 with a dead zone; buttons are booleans updated at pollHz.
class GamepadBridge : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(bool connected READ connected NOTIFY stateChanged)
    Q_PROPERTY(QString name READ name NOTIFY stateChanged)
    Q_PROPERTY(double axisX READ axisX NOTIFY stateChanged)
    Q_PROPERTY(double axisY READ axisY NOTIFY stateChanged)
    Q_PROPERTY(bool south READ south NOTIFY stateChanged)      // A / Cross
    Q_PROPERTY(bool east READ east NOTIFY stateChanged)        // B / Circle
    Q_PROPERTY(bool west READ west NOTIFY stateChanged)        // X / Square
    Q_PROPERTY(bool north READ north NOTIFY stateChanged)      // Y / Triangle
    Q_PROPERTY(bool leftShoulder READ leftShoulder NOTIFY stateChanged)
    Q_PROPERTY(bool rightShoulder READ rightShoulder NOTIFY stateChanged)
    Q_PROPERTY(bool leftTrigger READ leftTrigger NOTIFY stateChanged)
    Q_PROPERTY(bool rightTrigger READ rightTrigger NOTIFY stateChanged)
    Q_PROPERTY(bool select READ select NOTIFY stateChanged)
    Q_PROPERTY(bool start READ start NOTIFY stateChanged)
    Q_PROPERTY(bool dpadUp READ dpadUp NOTIFY stateChanged)
    Q_PROPERTY(bool dpadDown READ dpadDown NOTIFY stateChanged)
    Q_PROPERTY(bool dpadLeft READ dpadLeft NOTIFY stateChanged)
    Q_PROPERTY(bool dpadRight READ dpadRight NOTIFY stateChanged)
    Q_PROPERTY(int pollHz READ pollHz WRITE setPollHz NOTIFY pollHzChanged)
    Q_PROPERTY(double deadZone READ deadZone WRITE setDeadZone NOTIFY deadZoneChanged)
public:
    explicit GamepadBridge(QObject *parent = nullptr);

    bool available() const;
    bool connected() const { return m_connected; }
    QString name() const { return m_name; }
    double axisX() const { return m_axisX; }
    double axisY() const { return m_axisY; }
    bool south() const { return button(0); }
    bool east() const { return button(1); }
    bool west() const { return button(2); }
    bool north() const { return button(3); }
    bool leftShoulder() const { return button(4); }
    bool rightShoulder() const { return button(5); }
    bool leftTrigger() const { return button(6); }
    bool rightTrigger() const { return button(7); }
    bool select() const { return button(8); }
    bool start() const { return button(9); }
    bool dpadUp() const { return button(12); }
    bool dpadDown() const { return button(13); }
    bool dpadLeft() const { return button(14); }
    bool dpadRight() const { return button(15); }
    int pollHz() const { return m_pollHz; }
    void setPollHz(int hz);
    double deadZone() const { return m_deadZone; }
    void setDeadZone(double dz);

    /// Test hook (and the desktop fallback for tools): inject a synthetic state.
    Q_INVOKABLE void injectState(bool connected, double axisX, double axisY, int buttonMask);

signals:
    void stateChanged();
    void pollHzChanged();
    void deadZoneChanged();

private:
    void poll();
    bool button(int index) const { return (m_buttons >> index) & 1; }
    void apply(bool connected, const QString &name, double ax, double ay, quint32 buttons);

    QTimer m_timer;
    bool m_connected = false;
    QString m_name;
    double m_axisX = 0, m_axisY = 0;
    quint32 m_buttons = 0;
    int m_pollHz = 60;
    double m_deadZone = 0.22;
};
