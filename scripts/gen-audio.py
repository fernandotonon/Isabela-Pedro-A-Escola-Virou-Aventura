#!/usr/bin/env python3
"""Generate the game's audio: original, synthesized, licence-free (no external samples).

    python3 scripts/gen-audio.py [out_dir=assets/audio]

Pure Python (wave + math): short effects plus three music loops (cheerful outdoors, curious
indoors, a short ending fanfare). Deterministic (seeded), so re-running reproduces the files.
"""
import math
import os
import random
import struct
import sys
import wave

SR = 22050
random.seed(2026)


def write_wav(path, samples):
    data = b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples)
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(data)


def env(i, n, a=0.005, r=0.2):
    t = i / SR; total = n / SR
    at = min(1.0, t / a) if a > 0 else 1.0
    rel = min(1.0, (total - t) / max(r, 1e-4)) if r > 0 else 1.0
    return max(0.0, min(at, rel))


def sine(ph): return math.sin(ph)
def square(ph): return 1.0 if math.sin(ph) >= 0 else -1.0
def saw(ph): return (ph / math.pi) % 2 - 1
def tri(ph): return 2 * abs(saw(ph)) - 1


def tone(freq, dur, wave_fn=sine, vol=0.6, a=0.005, r=0.15, slide=0.0, vib=0.0, harm=0.0):
    n = int(SR * dur); out = []; ph = 0.0
    for i in range(n):
        f = freq * (1 + slide * i / n) * (1 + vib * math.sin(2 * math.pi * 6 * i / SR))
        ph += 2 * math.pi * f / SR
        s = wave_fn(ph) + harm * math.sin(2 * ph) * 0.5
        out.append(vol * env(i, n, a, r) * s)
    return out


def noise(dur, vol=0.5, a=0.002, r=0.12, lowpass=0.2):
    n = int(SR * dur); out = []; y = 0.0
    for i in range(n):
        x = random.uniform(-1, 1)
        y += lowpass * (x - y)
        out.append(vol * env(i, n, a, r) * y)
    return out


def mix(*parts):
    n = max(len(p) for p in parts); out = [0.0] * n
    for p in parts:
        for i, s in enumerate(p): out[i] += s
    peak = max(1e-6, max(abs(s) for s in out))
    return [s / peak * 0.9 for s in out] if peak > 0.9 else out


def concat(*parts):
    out = []
    for p in parts: out += p
    return out


def silence(dur): return [0.0] * int(SR * dur)


def place(canvas, samples, at):
    i0 = int(at * SR)
    for i, s in enumerate(samples):
        if i0 + i < len(canvas): canvas[i0 + i] += s
    return canvas


def midi(n): return 440.0 * 2 ** ((n - 69) / 12)


def pluck(freq, dur, vol=0.5):  # bright plucked string / xylophone-like
    return mix(tone(freq, dur, sine, vol, 0.002, dur * 0.8, harm=0.8), tone(freq * 2, dur * 0.6, sine, vol * 0.25, 0.002, dur * 0.5))


def sfx():
    return {
        "jump": tone(320, 0.18, square, 0.35, 0.002, 0.08, slide=0.9),
        "land": mix(noise(0.09, 0.5, 0.001, 0.07, 0.35), tone(120, 0.08, sine, 0.5, 0.001, 0.06, slide=-0.4)),
        "step_grass": noise(0.06, 0.35, 0.001, 0.05, 0.12),
        "step_concrete": mix(noise(0.05, 0.3, 0.001, 0.04, 0.5), tone(210, 0.04, sine, 0.2, 0.001, 0.03)),
        "step_metal": mix(tone(880, 0.09, tri, 0.25, 0.001, 0.08), tone(1320, 0.07, sine, 0.12, 0.001, 0.06), noise(0.03, 0.2, 0.001, 0.02, 0.6)),
        "collect_star": concat(tone(midi(76), 0.08, sine, 0.5, 0.002, 0.04), tone(midi(83), 0.16, sine, 0.5, 0.002, 0.12, harm=0.5)),
        "collect_pencil": concat(tone(midi(72), 0.07, tri, 0.5), tone(midi(76), 0.07, tri, 0.5), tone(midi(79), 0.07, tri, 0.5), tone(midi(84), 0.22, tri, 0.55, 0.002, 0.18)),
        "collect_memory": mix(concat(tone(midi(67), 0.18, sine, 0.45), tone(midi(71), 0.18, sine, 0.45), tone(midi(74), 0.18, sine, 0.45), tone(midi(79), 0.6, sine, 0.5, 0.01, 0.5, harm=0.4)),
                              concat(silence(0.3), tone(midi(55), 0.9, sine, 0.3, 0.05, 0.6))),
        "switch_char": concat(tone(520, 0.06, square, 0.3, 0.001, 0.03), tone(780, 0.1, square, 0.3, 0.001, 0.08)),
        "mechanism": mix(concat(tone(180, 0.12, square, 0.35, 0.002, 0.05), tone(260, 0.2, square, 0.35, 0.002, 0.15)), noise(0.25, 0.25, 0.01, 0.2, 0.3)),
        "gate_open": mix(tone(90, 0.9, saw, 0.3, 0.05, 0.5, slide=0.3), noise(0.9, 0.2, 0.05, 0.6, 0.15), concat(silence(0.6), tone(660, 0.3, sine, 0.3, 0.01, 0.25))),
        "courage_lose": concat(tone(440, 0.09, square, 0.35, 0.002, 0.04, slide=-0.3), tone(300, 0.18, square, 0.3, 0.002, 0.14, slide=-0.4)),
        "courage_out": mix(concat(tone(330, 0.2, sine, 0.4), tone(262, 0.25, sine, 0.4), tone(196, 0.5, sine, 0.4, 0.01, 0.4)), noise(0.9, 0.12, 0.2, 0.5, 0.08)),
        "checkpoint": concat(tone(midi(72), 0.1, tri, 0.45), tone(midi(79), 0.1, tri, 0.45), tone(midi(84), 0.28, tri, 0.5, 0.002, 0.22, harm=0.4)),
        "bell": mix(tone(1046, 1.6, sine, 0.5, 0.002, 1.4, harm=0.3), tone(1568, 1.1, sine, 0.25, 0.002, 1.0), tone(2093, 0.7, sine, 0.12, 0.002, 0.6),
                    concat(silence(0.5), tone(1046, 1.4, sine, 0.45, 0.002, 1.3, harm=0.3))),
        "push": noise(0.22, 0.3, 0.02, 0.15, 0.08),
        "metal": mix(tone(660, 0.25, tri, 0.35, 0.001, 0.22), tone(990, 0.18, sine, 0.15, 0.001, 0.16), noise(0.04, 0.3, 0.001, 0.03, 0.7)),
        "ball_bounce": mix(tone(160, 0.12, sine, 0.5, 0.001, 0.1, slide=-0.5), noise(0.05, 0.2, 0.001, 0.04, 0.3)),
        "level_complete": concat(tone(midi(72), 0.14, tri, 0.5), tone(midi(76), 0.14, tri, 0.5), tone(midi(79), 0.14, tri, 0.5), tone(midi(84), 0.3, tri, 0.5), tone(midi(79), 0.14, tri, 0.5), tone(midi(84), 0.7, tri, 0.55, 0.005, 0.6, harm=0.5)),
        "ui_move": tone(600, 0.05, square, 0.2, 0.001, 0.03),
        "ui_accept": concat(tone(700, 0.06, square, 0.25, 0.001, 0.03), tone(1050, 0.12, square, 0.25, 0.001, 0.1)),
        "reveal": mix(concat(tone(midi(74), 0.1, sine, 0.4), tone(midi(78), 0.1, sine, 0.4), tone(midi(81), 0.1, sine, 0.4), tone(midi(86), 0.5, sine, 0.45, 0.01, 0.45, vib=0.01)), noise(0.6, 0.1, 0.1, 0.4, 0.05)),
        "whoosh": noise(0.35, 0.4, 0.08, 0.2, 0.06),
        "grab": mix(noise(0.06, 0.35, 0.001, 0.05, 0.4), tone(240, 0.08, sine, 0.3, 0.001, 0.06)),
    }


def music_outdoor():
    # C major pentatonic, bouncy 2-bar bass + melody, 120 bpm, 24 s
    bpm = 120; beat = 60 / bpm; total = 24.0
    canvas = [0.0] * int(SR * total)
    bass = [48, 48, 55, 55, 53, 53, 55, 55]
    melody_bank = [72, 74, 76, 79, 81, 84, 79, 76]
    t = 0.0; k = 0
    while t < total - 0.01:
        b = bass[k % len(bass)]
        place(canvas, tone(midi(b), beat * 0.9, tri, 0.28, 0.01, 0.15), t)
        place(canvas, tone(midi(b + 12), beat * 0.45, square, 0.06, 0.005, 0.1), t + beat * 0.5)
        if k % 2 == 0:
            m = melody_bank[(k * 3 + (k // 8)) % len(melody_bank)]
            place(canvas, pluck(midi(m), beat * 1.2, 0.32), t)
            place(canvas, pluck(midi(m + (2 if (k // 2) % 3 else 4)), beat * 0.7, 0.2), t + beat)
        # light hat
        place(canvas, noise(0.03, 0.12, 0.001, 0.025, 0.7), t + beat * 0.5)
        t += beat; k += 1
    return mix(canvas)


def music_indoor():
    # A minor "curious" arpeggios with a slow bass, 100 bpm, 24 s
    bpm = 100; beat = 60 / bpm; total = 24.0
    canvas = [0.0] * int(SR * total)
    chords = [[57, 60, 64, 67], [55, 59, 62, 65], [53, 57, 60, 64], [55, 59, 62, 67]]
    t = 0.0; k = 0
    while t < total - 0.01:
        ch = chords[(k // 4) % len(chords)]
        place(canvas, tone(midi(ch[0] - 12), beat * 3.6, sine, 0.25, 0.05, 0.8), t) if k % 4 == 0 else None
        n = ch[(k % 4)] + 12
        place(canvas, pluck(midi(n), beat * 0.9, 0.28), t)
        place(canvas, pluck(midi(n + 7), beat * 0.4, 0.12), t + beat * 0.5)
        if k % 8 == 7:
            place(canvas, tone(midi(ch[2] + 12), beat * 1.5, sine, 0.15, 0.02, 1.0, vib=0.01), t)
        t += beat; k += 1
    return mix(canvas)


def music_end():
    beat = 0.22
    seq = [72, 76, 79, 84, 83, 84, 88]
    canvas = [0.0] * int(SR * 6.0)
    t = 0.0
    for i, n in enumerate(seq):
        d = beat * (3.0 if i == len(seq) - 1 else 1.0)
        place(canvas, tone(midi(n), d * 1.1, tri, 0.4, 0.005, d * 0.6, harm=0.4), t)
        place(canvas, tone(midi(n - 12), d * 1.1, sine, 0.25, 0.005, d * 0.6), t)
        t += d
    place(canvas, tone(midi(60), 2.5, sine, 0.25, 0.05, 1.8), t - beat)
    place(canvas, tone(midi(67), 2.5, sine, 0.2, 0.05, 1.8), t - beat)
    return mix(canvas)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
    os.makedirs(out, exist_ok=True)
    for name, samples in sfx().items():
        write_wav(os.path.join(out, name + ".wav"), samples)
    write_wav(os.path.join(out, "music_outdoor.wav"), music_outdoor())
    write_wav(os.path.join(out, "music_indoor.wav"), music_indoor())
    write_wav(os.path.join(out, "music_end.wav"), music_end())
    total = sum(os.path.getsize(os.path.join(out, f)) for f in os.listdir(out) if f.endswith(".wav"))
    print(f"wrote {len(os.listdir(out))} files to {out} ({total / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()
