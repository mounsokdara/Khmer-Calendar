#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, cpSync, rmSync } from "node:fs";
import { join } from "node:path";
import { writeOfflineWorker as injectOfflineWorker } from "./offline-worker.mjs";

const root = process.cwd();
const app = join(root, "khmer_calendar");
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

function flutterWorks(bin) {
  try {
    const r = spawnSync(bin, ["--version"], { encoding: "utf8", timeout: 20000 });
    return r.status === 0;
  } catch {
    return false;
  }
}

function run(bin, args, cwd = app) {
  const r = spawnSync(bin, args, { cwd, stdio: "inherit", env: process.env });
  if (r.status !== 0) process.exit(r.status ?? 1);
}

function isFlutterWebsite(dir) {
  return existsSync(join(dir, "index.html")) && existsSync(join(dir, "flutter.js"));
}

function copyDir(src, dest) {
  if (src === dest) return;
  rmSync(dest, { recursive: true, force: true });
  mkdirSync(dest, { recursive: true });
  cpSync(src, dest, { recursive: true });
}

function writeOfflineWorker(siteDir) {
  injectOfflineWorker(siteDir, app);
}

const watchMode = process.env.FLUTTER_WEB_WATCH === "1";
const skipPubGet = watchMode || process.env.SKIP_PUB_GET === "1";

const bin = flutterBin();
if (!flutterWorks(bin)) {
  console.error("Flutter SDK not found. The website is built from source (khmer_calendar/); nothing is committed.");
  process.exit(1);
}

if (!skipPubGet) run(bin, ["pub", "get"]);
run(bin, ["build", "web", "--release", "--no-web-resources-cdn", "--base-href", "/"]);

const out = join(app, "build/web");
if (!isFlutterWebsite(out)) {
  console.error("Flutter web build did not produce flutter.js");
  process.exit(1);
}
writeOfflineWorker(out);
if (!watchMode) {
  copyDir(out, join(root, "dist"));
  copyDir(out, join(root, "flutter-web"));
  console.log("Flutter website staged to dist/ and flutter-web/ with local CanvasKit and offline worker");
} else {
  console.log("Flutter website rebuilt for preview");
}
