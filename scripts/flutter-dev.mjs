#!/usr/bin/env node
import { spawn, spawnSync } from "node:child_process";
import { createReadStream, existsSync, readdirSync, statSync, watch } from "node:fs";
import { createServer } from "node:http";
import { extname, join, resolve } from "node:path";

const root = process.cwd();
const app = join(root, "khmer_calendar");
const web = join(app, "build", "web");
const buildScript = join(root, "scripts/flutter-build.mjs");

function anyNewer(dir, thanMs) {
  if (!existsSync(dir)) return false;
  const st = statSync(dir);
  if (st.mtimeMs > thanMs) return true;
  if (!st.isDirectory()) return false;
  for (const name of readdirSync(dir)) {
    if (name.startsWith(".")) continue;
    if (anyNewer(join(dir, name), thanMs)) return true;
  }
  return false;
}

function dartIsNewerThanBuild() {
  const mainJs = join(web, "main.dart.js");
  if (!existsSync(join(web, "index.html")) || !existsSync(mainJs)) return true;
  const built = statSync(mainJs).mtimeMs;
  return (
    anyNewer(join(app, "lib"), built) ||
    anyNewer(join(app, "web"), built) ||
    anyNewer(join(app, "assets"), built) ||
    (existsSync(join(app, "pubspec.yaml")) && statSync(join(app, "pubspec.yaml")).mtimeMs > built)
  );
}

function runBuild(watchMode) {
  const env = { ...process.env };
  if (watchMode) {
    env.SKIP_PUB_GET = "1";
    env.FLUTTER_WEB_WATCH = "1";
  }
  const r = spawnSync(process.execPath, [buildScript], { cwd: root, stdio: "inherit", env });
  return r.status === 0;
}

function ensureBuild() {
  if (!dartIsNewerThanBuild()) return;
  console.log("Dart is newer than the website build — rebuilding…");
  if (!runBuild(false)) process.exit(1);
}

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".mjs": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".wasm": "application/wasm",
  ".map": "application/json",
  ".ico": "image/x-icon",
  ".webmanifest": "application/manifest+json",
};

ensureBuild();

let building = false;
let pending = false;
let timer;

function rebuild() {
  if (building) {
    pending = true;
    return;
  }
  building = true;
  console.log("Dart changed — rebuilding website…");
  const env = { ...process.env, SKIP_PUB_GET: "1", FLUTTER_WEB_WATCH: "1" };
  const child = spawn(process.execPath, [buildScript], { cwd: root, stdio: "inherit", env });
  child.on("exit", (code) => {
    building = false;
    if (code === 0) console.log("Website preview updated. Refresh to see it.");
    else console.error("Website rebuild failed");
    if (pending) {
      pending = false;
      rebuild();
    }
  });
}

function scheduleRebuild() {
  clearTimeout(timer);
  timer = setTimeout(rebuild, 1200);
}

function watchTree(p) {
  if (!existsSync(p)) return;
  try {
    watch(p, { recursive: true }, (_event, filename) => {
      const name = filename ? String(filename) : "";
      if (name.endsWith(".map") || name.startsWith(".")) return;
      scheduleRebuild();
    });
  } catch (err) {
    console.error("watch failed", p, err);
  }
}

watchTree(join(app, "lib"));
watchTree(join(app, "web"));
watchTree(join(app, "assets"));
if (existsSync(join(app, "pubspec.yaml"))) {
  watch(join(app, "pubspec.yaml"), () => scheduleRebuild());
}

const server = createServer((req, res) => {
  const raw = decodeURIComponent((req.url ?? "/").split("?")[0] || "/");
  let rel = raw === "/" ? "index.html" : raw.replace(/^\//, "");
  let file = resolve(web, rel);
  const rootResolved = resolve(web);
  if (!file.startsWith(rootResolved)) {
    res.statusCode = 403;
    res.end("forbidden");
    return;
  }
  const send = (path) => {
    const st = statSync(path);
    if (st.isDirectory()) path = join(path, "index.html");
    const type = MIME[extname(path).toLowerCase()] ?? "application/octet-stream";
    res.statusCode = 200;
    res.setHeader("content-type", type);
    res.setHeader("cache-control", "no-cache");
    if (req.method === "HEAD") {
      res.end();
      return;
    }
    createReadStream(path).pipe(res);
  };
  try {
    if (existsSync(file) && statSync(file).isFile()) {
      send(file);
      return;
    }
    if (existsSync(file) && statSync(file).isDirectory() && existsSync(join(file, "index.html"))) {
      send(join(file, "index.html"));
      return;
    }
    send(join(web, "index.html"));
  } catch {
    res.statusCode = 404;
    res.end("not found");
  }
});

server.listen(8080, "0.0.0.0", () => {
  console.log("Khmer Calendar (Flutter web) http://0.0.0.0:8080 — watching Dart");
});
