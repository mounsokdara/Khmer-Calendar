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

function run(bin, args, cwd = app) {
  const r = spawnSync(bin, args, { cwd, stdio: "inherit", env: process.env });
  if (r.status !== 0) process.exit(r.status ?? 1);
}

const bin = flutterBin();
run(bin, ["pub", "get"]);
run(bin, ["build", "web", "--release", "--no-web-resources-cdn", "--base-href", "/"]);

const out = join(app, "build/web");
const dest = join(root, "flutter-web");
rmSync(dest, { recursive: true, force: true });
mkdirSync(dest, { recursive: true });
cpSync(out, dest, { recursive: true });
