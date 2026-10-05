#!/usr/bin/env node
// Static preview of the built Flutter web app on 127.0.0.1:8081 (what
// `npm run preview` serves). No Vite and no npm dependencies: it only serves
// khmer_calendar/build/web as it is on disk. Build first: `npm run build:web`.
import { createReadStream, existsSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join, resolve } from "node:path";

const web = resolve(process.cwd(), "khmer_calendar", "build", "web");
const PORT = 8081;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".mjs": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".wasm": "application/wasm",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".txt": "text/plain; charset=utf-8",
  ".webmanifest": "application/manifest+json; charset=utf-8",
};

if (!existsSync(join(web, "index.html"))) {
  console.error(`No Flutter web build at ${web}. Run: npm run build:web`);
  process.exit(1);
}

const server = createServer((req, res) => {
  let rel;
  try {
    rel = decodeURIComponent((req.url ?? "/").split("?")[0] || "/");
  } catch {
    res.statusCode = 400;
    res.end("bad request");
    return;
  }
  const file = resolve(web, "." + (rel.startsWith("/") ? rel : `/${rel}`));
  if (file !== web && !file.startsWith(web + "/")) {
    res.statusCode = 403;
    res.end("forbidden");
    return;
  }
  let target = file;
  try {
    if (statSync(target).isDirectory()) target = join(target, "index.html");
    if (!statSync(target).isFile()) throw new Error("not a file");
  } catch {
    // Single-page app fallback, same as khmer_calendar/web/_redirects.
    target = join(web, "index.html");
  }
  res.statusCode = 200;
  res.setHeader("content-type", MIME[extname(target).toLowerCase()] ?? "application/octet-stream");
  res.setHeader("cache-control", "no-cache");
  if (req.method === "HEAD") {
    res.end();
    return;
  }
  createReadStream(target).pipe(res);
});

server.on("error", (err) => {
  console.error(`preview failed on 127.0.0.1:${PORT}: ${err.message}`);
  process.exit(1);
});
server.listen(PORT, "127.0.0.1", () => {
  console.log(`Khmer Calendar (Flutter web build) http://127.0.0.1:${PORT}/`);
});
