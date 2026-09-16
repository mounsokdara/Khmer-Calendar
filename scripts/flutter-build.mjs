#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, cpSync, rmSync, readdirSync, statSync, readFileSync, writeFileSync } from "node:fs";
import { join, relative, sep } from "node:path";

const root = process.cwd();
const app = join(root, "khmer_calendar");
const website = join(root, "website");
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

function isCloudflareHost() {
  return Boolean(
    process.env.CF_PAGES ||
      process.env.CF_PAGES_BRANCH ||
      process.env.WORKERS_CI ||
      process.env.CLOUDFLARE_ACCOUNT_ID ||
      process.env.CLOUDFLARE,
  );
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

function walkFiles(dir, base = dir, out = []) {
  if (!existsSync(dir)) return out;
  for (const name of readdirSync(dir)) {
    if (name.startsWith(".")) continue;
    const p = join(dir, name);
    if (statSync(p).isDirectory()) {
      walkFiles(p, base, out);
      continue;
    }
    const rel = "./" + relative(base, p).split(sep).join("/");
    if (rel.endsWith(".map")) continue;
    if (rel.includes("/weather/")) continue;
    out.push(rel);
  }
  return out;
}

function writeOfflineWorker(siteDir) {
  const template = readFileSync(join(app, "web/offline.js"), "utf8");
  const files = walkFiles(siteDir);
  const stamp = Date.now();
  const injected = template
    .replace(/const CACHE = '[^']+';/, `const CACHE = 'khmer-calendar-web-${stamp}';`)
    .replace(/const PRECACHE = \[[\s\S]*?\];/, `const PRECACHE = ${JSON.stringify(files, null, 2)};`);
  writeFileSync(join(siteDir, "offline.js"), injected);
  writeFileSync(join(siteDir, "flutter_service_worker.js"), injected);
}

function stageWebsite(src) {
  writeOfflineWorker(src);
  copyDir(src, join(root, "dist"));
  copyDir(src, join(root, "flutter-web"));
}

function useCommittedWebsite() {
  if (!isFlutterWebsite(website)) {
    console.error("No Flutter SDK here, and website/ is missing the Flutter web app.");
    console.error("The public site is the Flutter app. Do not fall back to the old HTML app.");
    process.exit(1);
  }
  console.log("Using the committed Flutter website (same UI as the app preview).");
  stageWebsite(website);
}

const bin = flutterBin();
if (isCloudflareHost() || !flutterWorks(bin)) {
  useCommittedWebsite();
  process.exit(0);
}

run(bin, ["pub", "get"]);
run(bin, ["build", "web", "--release", "--no-web-resources-cdn", "--base-href", "/"]);

const out = join(app, "build/web");
if (!isFlutterWebsite(out)) {
  console.error("Flutter web build did not produce flutter.js");
  process.exit(1);
}
writeOfflineWorker(out);
copyDir(out, join(root, "dist"));
copyDir(out, join(root, "flutter-web"));
copyDir(out, website);
console.log("Flutter website staged to dist/, flutter-web/, and website/ with local CanvasKit and offline worker");
