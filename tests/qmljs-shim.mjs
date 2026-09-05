// Load Qt QML JavaScript modules (.pragma library + .import "x.js" as Y) in plain Node, so the
// pure-JS game systems can be checked in a second without a Qt build (`node tests/run-node.mjs`).
// A module's top-level `function name` and `var name` declarations become its exports.
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";

const cache = new Map();

export function loadQmlJs(file) {
  const path = resolve(file);
  if (cache.has(path)) return cache.get(path);
  let src = readFileSync(path, "utf8");
  const deps = [];
  src = src.replace(/^\s*\.pragma\s+library\s*$/gm, "");
  src = src.replace(/^\s*\.import\s+"([^"]+)"\s+as\s+(\w+)\s*$/gm, (_, rel, name) => {
    deps.push([name, resolve(dirname(path), rel)]);
    return "";
  });
  const names = new Set();
  for (const m of src.matchAll(/^function\s+(\w+)\s*\(/gm)) names.add(m[1]);
  for (const m of src.matchAll(/^var\s+(\w+)\s*[=;]/gm)) names.add(m[1]);
  const exportsObj = [...names].map(n => `${n}: ${n}`).join(", ");
  const argNames = deps.map(d => d[0]);
  const argValues = deps.map(d => loadQmlJs(d[1]));
  const factory = new Function(...argNames, `${src}\nreturn { ${exportsObj} };`);
  const mod = factory(...argValues);
  cache.set(path, mod);
  return mod;
}
