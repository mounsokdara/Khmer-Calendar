#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { createReadStream, existsSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join, normalize, relative, resolve } from "node:path";

const root = process.cwd();
const app = join(root, "khmer_calendar");
const web = join(app, "build", "web");
const candidates = [
  process.env.FLUTTER,
  process.env.FLUTTER_ROOT ? join(process.env.FLUTTER_ROOT, "bin/flutter") : null,
  "/opt/flutter-sdk/flutter/bin/flutter",
  "flutter",
].filter(Boolean);

function flutterBin() {
  for (const c of candidates) {
    if (c === "flutter") return c;
    if (existsSync(c)) return c;
  }
  return "flutter";
}

function ensureBuild() {
  if (existsSync(join(web, "index.html")) && existsSync(join(web, "main.dart.js"))) return;
  const bin = flutterBin();
  const r = spawnSync(bin, ["build", "web", "--release", "--no-web-resources-cdn", "--base-href", "/"], {
    cwd: app,
    stdio: "inherit",
    env: process.env,
  });
  if (r.status !== 0) process.exit(r.status ?? 1);
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
  console.log("Khmer Calendar (Flutter web) http://0.0.0.0:8080");
});
