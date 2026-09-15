#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, cpSync, rmSync } from "node:fs";
import { join } from "node:path";

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

function stageWebsite(src) {
  const dests = [join(root, "dist"), join(root, "flutter-web")];
  for (const dest of dests) {
    if (src === dest) continue;
    rmSync(dest, { recursive: true, force: true });
    mkdirSync(dest, { recursive: true });
    cpSync(src, dest, { recursive: true });
  }
}

function viteWebsite() {
  console.log("Flutter SDK is not available on this host. Building the website with Vite.");
  const r = spawnSync(process.execPath, [join(root, "scripts/with-app-env.mjs"), "vite", "build"], {
    cwd: root,
    stdio: "inherit",
    env: process.env,
  });
  if (r.status !== 0) process.exit(r.status ?? 1);
  const sources = [
    join(root, ".output/public"),
    join(root, ".vercel/output/static"),
    join(root, "dist"),
    join(root, "client"),
  ];
  const src = sources.find((s) => existsSync(join(s, "index.html")));
  if (src) {
    stageWebsite(src);
    console.log(`Website static files staged from ${src}`);
  }
}

const bin = flutterBin();
if (isCloudflareHost() || !flutterWorks(bin)) {
  viteWebsite();
  process.exit(0);
}

run(bin, ["pub", "get"]);
run(bin, ["build", "web", "--release", "--no-web-resources-cdn", "--base-href", "/"]);

const out = join(app, "build/web");
stageWebsite(out);
