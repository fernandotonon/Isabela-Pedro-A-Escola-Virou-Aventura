// Placeholder geometry: every manifest entry without a model/sprite is drawn as a few toon boxes
// (Clayground.Canvas3D Box3D). `parts(shape, w, h, d, ph)` returns a list of primitives:
//   { type: "box"|"sphere"|"cylinder", x, y, z, w, h, d, color, edges }
// x/z are offsets from the entity's bottom-centre origin, y is the part's bottom. Swapping a
// placeholder for a QtMeshEditor model is a manifest change; nothing here is gameplay.
.pragma library

function part(x, y, z, w, h, d, color, type, edges) {
    return { type: type || "box", x: x, y: y, z: z, w: w, h: h, d: d, color: color, edges: edges === undefined ? true : edges }
}

function parts(shape, w, h, d, ph) {
    const c = ph.color || "#c98a3e", a = ph.accent || "#2b2b2b"
    switch (shape) {
    case "bench":
        return [part(0, h - 0.12, 0, w, 0.12, d * 0.9, c), part(0, h * 0.75, -d * 0.4, w, h * 0.35, 0.08, c),
                part(-w * 0.4, 0, 0, 0.12, h - 0.12, d * 0.8, a), part(w * 0.4, 0, 0, 0.12, h - 0.12, d * 0.8, a)]
    case "planter":
        return [part(0, 0, 0, w, h * 0.6, d, a), part(0, h * 0.55, 0, w * 0.92, h * 0.45, d * 0.9, c),
                part(-w * 0.25, h, 0, 0.3, 0.35, 0.3, "#e33f3f"), part(w * 0.2, h, 0.1, 0.25, 0.3, 0.25, "#f2c530"), part(0.05, h, -0.15, 0.25, 0.4, 0.25, "#f4f4f8")]
    case "tires": {
        const n = Math.max(1, Math.round(h / 0.34)); const out = []
        const cols = [c, a, "#2a5bd7"]
        for (let i = 0; i < n; ++i) out.push(part(0, i * (h / n), 0, w, h / n - 0.02, d, cols[i % 3], "cylinder"))
        out.push(part(0, h, 0, w * 0.5, 0.3, d * 0.5, "#5da84a")); return out
    }
    case "bars":
        return [part(-w * 0.45, 0, 0, 0.12, h, 0.12, c), part(w * 0.45, 0, 0, 0.12, h, 0.12, c), part(0, h - 0.12, 0, w, 0.12, 0.12, c),
                part(-w * 0.45, 0, d * 0.5, 0.12, h * 0.55, 0.12, c), part(w * 0.45, 0, d * 0.5, 0.12, h * 0.55, 0.12, c), part(0, h * 0.55 - 0.12, d * 0.5, w, 0.12, 0.12, c)]
    case "books": {
        const cols = [c, a, "#f2c530", "#3a9a4a"]; const out = []; const n = Math.max(2, Math.round(h / 0.3)); const bh = h / n
        for (let i = 0; i < n; ++i) out.push(part((i % 2) * 0.06 - 0.03, i * bh, 0, w * (0.9 + 0.1 * (i % 2)), bh - 0.02, d, cols[i % cols.length]))
        return out
    }
    case "plane":
        return [part(0, 0, 0, w, h, d * 0.25, c), part(-w * 0.2, 0, d * 0.35, w * 0.5, h * 0.7, d * 0.3, "#e6e6ee"), part(-w * 0.2, 0, -d * 0.35, w * 0.5, h * 0.7, d * 0.3, "#e6e6ee")]
    case "playground":
        return [part(-w * 0.3, 0, 0, 0.18, h * 0.8, 0.18, "#e33f3f"), part(w * 0.3, 0, 0, 0.18, h * 0.8, 0.18, "#2a5bd7"), part(-w * 0.3, 0, d * 0.5, 0.18, h * 0.8, 0.18, "#2a5bd7"), part(w * 0.3, 0, d * 0.5, 0.18, h * 0.8, 0.18, "#e33f3f"),
                part(0, h * 0.5, d * 0.25, w * 0.7, 0.2, d * 0.7, c), part(0, h * 0.85, d * 0.25, w * 0.8, 0.15, d * 0.8, "#7d8288"),
                part(w * 0.62, 0.3, d * 0.25, w * 0.35, 0.25, 0.9, "#f07a2a")]
    case "tunnel": {
        const cols = ["#2a5bd7", "#f2c530", "#e33f3f"]; const out = []; const n = Math.max(1, Math.round(w / 1.1))
        for (let i = 0; i < n; ++i) out.push(part(-w / 2 + (i + 0.5) * (w / n), 0, 0, w / n - 0.05, h, d, cols[i % 3], "cylinder"))
        return out
    }
    case "pencil":
        return [part(0, 0, 0, w * 0.8, h, h, c), part(w * 0.45, 0, 0, w * 0.12, h, h, "#e6c9a0"), part(w * 0.52, h * 0.3, 0, w * 0.05, h * 0.4, h * 0.4, "#2b2b2b"), part(-w * 0.45, 0, 0, w * 0.1, h, h, a)]
    case "desk":
        return [part(-w * 0.15, h - 0.08, 0, w * 0.7, 0.08, d, c), part(-w * 0.4, 0, 0, 0.08, h - 0.08, d * 0.9, a), part(w * 0.1, 0, 0, 0.08, h - 0.08, d * 0.9, a),
                part(w * 0.35, h * 0.35, 0, w * 0.3, 0.06, d * 0.6, a), part(w * 0.48, h * 0.35, 0, 0.06, h * 0.45, d * 0.6, a)]
    case "table":
        return [part(0, h - 0.1, 0, w, 0.1, d, c), part(-w * 0.42, 0, -d * 0.35, 0.1, h - 0.1, 0.1, a), part(w * 0.42, 0, -d * 0.35, 0.1, h - 0.1, 0.1, a),
                part(-w * 0.42, 0, d * 0.35, 0.1, h - 0.1, 0.1, a), part(w * 0.42, 0, d * 0.35, 0.1, h - 0.1, 0.1, a), part(0, h, 0, 0.06, 0.18, d, "#f4f4f8")]
    case "corridor":
        return [part(0, 0, -d * 0.5, w, h, 0.3, c, "box", false), part(0, h * 0.42, -d * 0.5 + 0.16, w, h * 0.04, 0.05, a, "box", false),
                part(0, 0, 0, w, 0.05, d, "#4a4a52", "box", false)]
    case "court":
        return [part(0, 0, -d * 0.5, w, h, 0.3, "#d9e6ee", "box", false), part(0, 0, 0, w, 0.04, d, c, "box", false), part(0, 0.04, 0, w * 0.45, 0.02, d * 0.6, a, "box", false)]
    case "tree":
        return [part(0, 0, 0, 0.5, h * 0.42, 0.5, a, "cylinder"), part(0, h * 0.38, 0, h * 0.62, h * 0.62, h * 0.62, c, "sphere"), part(h * 0.25, h * 0.5, 0.1, h * 0.4, h * 0.4, h * 0.4, "#5fae47", "sphere")]
    case "gate":
        return [part(-w * 0.4, 0, 0, 0.14, h, 0.2, a), part(w * 0.4, 0, 0, 0.14, h, 0.2, a), part(0, h - 0.14, 0, w, 0.14, 0.2, a),
                part(-w * 0.15, 0, 0, 0.1, h - 0.14, 0.1, c), part(w * 0.15, 0, 0, 0.1, h - 0.14, 0.1, c), part(0, h * 0.5, 0, w, 0.1, 0.1, c)]
    case "fence": {
        const out = []; const n = Math.max(2, Math.round(w / 1.5))
        for (let i = 0; i <= n; ++i) out.push(part(-w / 2 + i * (w / n), 0, 0, 0.1, h, 0.1, c))
        out.push(part(0, h - 0.1, 0, w, 0.1, 0.08, c)); out.push(part(0, h * 0.45, 0, w, 0.08, 0.08, c)); return out
    }
    case "wall":
        return [part(0, 0, 0, w, h, d, c, "box", false), part(0, h * 0.7, d * 0.5, w, h * 0.06, 0.06, a, "box", false)]
    case "slab":
        return [part(0, 0, 0, w, h, d, c, "box", false)]
    case "lamp":
        return [part(0, 0, 0, 0.16, h, 0.16, c, "cylinder"), part(0, h, 0, 0.5, 0.35, 0.5, a, "sphere")]
    case "bush":
        return [part(0, 0, 0, w, h, d, c, "sphere"), part(w * 0.35, 0, 0.2, w * 0.7, h * 0.75, d * 0.7, "#4f9a3c", "sphere")]
    case "button":
        return [part(0, 0, 0, w, h * 0.45, d, a, "cylinder"), part(0, h * 0.45, 0, w * 0.8, h * 0.55, d * 0.8, c, "cylinder")]
    case "lever":
        return [part(0, 0, 0, w, h * 0.25, d, a), part(0, h * 0.25, 0, 0.08, h * 0.75, 0.08, c), part(0, h - 0.18, 0, 0.22, 0.22, 0.22, "#e33f3f", "sphere")]
    case "plate":
        return [part(0, 0, 0, w, h, d, c, "box", true), part(0, h, 0, w * 0.5, 0.01, d * 0.5, a, "box", false)]
    case "swing":
        return [part(0, 0, 0, w, h, d, c), part(-w * 0.4, h, 0, 0.06, 2.5, 0.06, "#7d8288", "box", false), part(w * 0.4, h, 0, 0.06, 2.5, 0.06, "#7d8288", "box", false)]
    case "beam":
        return [part(0, 0, 0, w, h, d, c, "box")]
    case "ladder": {
        const out = [part(-w * 0.35, 0, 0, 0.08, h, 0.08, c), part(w * 0.35, 0, 0, 0.08, h, 0.08, c)]
        for (let y = 0.3; y < h; y += 0.4) out.push(part(0, y, 0, w * 0.7, 0.06, 0.06, a))
        return out
    }
    case "deck":
        return [part(0, 0, 0, w, h, d, c), part(0, h, -d * 0.5, w, 0.6, 0.06, a, "box", true)]
    case "ball":
        return [part(0, 0, 0, w, h, d, c, "sphere"), part(0, h * 0.35, d * 0.45, w * 0.35, h * 0.3, d * 0.2, a, "box", false)]
    case "goal":
        return [part(-w * 0.45, 0, 0, 0.1, h, 0.1, c), part(w * 0.45, 0, 0, 0.1, h, 0.1, c), part(0, h - 0.1, 0, w, 0.1, 0.1, c), part(0, 0, -d * 0.5, w, h, 0.04, "#e9eef2", "box", false)]
    case "hoop":
        return [part(0, 0, 0, 0.18, h * 0.8, 0.18, "#7d8288"), part(0, h * 0.72, 0.35, 1.6, 1.1, 0.06, a), part(0, h * 0.72, 0.8, 0.5, 0.06, 0.5, c, "cylinder")]
    case "bleachers": {
        const out = []; const n = 3
        for (let i = 0; i < n; ++i) out.push(part(0, i * (h / n), -d * 0.5 + (i + 0.5) * (d / n), w, h / n, d / n, i % 2 ? c : a))
        return out
    }
    case "roof":
        return [part(0, h - 0.25, -d * 0.4, w, 0.25, d, c, "box", false), part(-w * 0.45, 0, -d * 0.8, 0.25, h, 0.25, c), part(w * 0.45, 0, -d * 0.8, 0.25, h, 0.25, c)]
    case "window":
        return [part(0, 0, 0, w, h, d, "#9fb7c9"), part(0, h, -d * 0.4, w * 0.95, 2.2, 0.08, c, "box", true), part(0, h + 1.1, -d * 0.4 + 0.02, w * 0.95, 0.06, 0.1, a, "box", false)]
    case "deskrow": {
        const out = []; const n = Math.max(1, Math.round(w / 1.6))
        for (let i = 0; i < n; ++i) { const cx = -w / 2 + (i + 0.5) * (w / n); out.push(part(cx, h - 0.08, 0, w / n - 0.2, 0.08, d, c)); out.push(part(cx - 0.5, 0, 0, 0.08, h - 0.08, d * 0.9, a)); out.push(part(cx + 0.5, 0, 0, 0.08, h - 0.08, d * 0.9, a)) }
        return out
    }
    case "clock":
        return [part(0, 0, 0, w, h, 0.15, c, "cylinder"), part(0, h * 0.5, 0.09, 0.06, h * 0.32, 0.03, a, "box", false), part(h * 0.12, h * 0.5, 0.09, h * 0.25, 0.06, 0.03, a, "box", false)]
    case "door":
        return [part(0, 0, 0, w, h, d, c), part(0, h * 0.45, d * 0.5, w * 0.35, h * 0.35, 0.04, a, "box", false), part(w * 0.3, h * 0.45, d * 0.5 + 0.02, 0.1, 0.1, 0.1, "#f2c530", "sphere")]
    case "star":
        return [part(0, 0, 0, w, h, d * 0.4, c, "box"), part(0, h * 0.15, 0, w * 0.7, h * 0.7, d * 0.5, c, "box")]
    case "flag":
        return [part(0, 0, 0, 0.12, h, 0.12, "#7d8288", "cylinder"), part(0.45, h * 0.62, 0, 0.9, h * 0.3, 0.06, c), part(0.45, h * 0.66, 0.04, 0.35, 0.35, 0.05, a)]
    case "photo":
        return [part(0, 0, 0, w, h, 0.06, c), part(0, h * 0.12, 0.04, w * 0.76, h * 0.7, 0.03, a, "box", false)]
    case "box":
    default:
        return [part(0, 0, 0, w, h, d, c)]
    }
}
