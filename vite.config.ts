import { readdirSync, createReadStream, statSync } from "node:fs";
import type { IncomingMessage, ServerResponse } from "node:http";
import { join } from "node:path";
import type { Plugin } from "vite";
import { defineConfig } from "vite";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import viteReact from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { nitro } from "nitro/vite";
// @ts-expect-error JS plugin alongside the TS vite config
import { appPwaPlugin } from "./scripts/app-pwa-plugin.mjs";
// @ts-expect-error JS plugin alongside the TS vite config
import { appEnvPlugin } from "./scripts/app-env-plugin.mjs";
import { isMigrationFile } from "./scripts/migration-plan.mjs";

function hasGlobbedMigrations(root: string): boolean {
  try {
    return readdirSync(join(root, "migrations")).some(isMigrationFile);
  } catch {
    return false;
  }
}

function pgliteBootstrapPlugin(): Plugin {
  return {
    name: "app-builder:pglite-bootstrap",
    apply: "serve",
    async configureServer(server) {
      if (!hasGlobbedMigrations(server.config.root)) return;
      try {
        const mod = (await server.ssrLoadModule("/src/lib/db.ts")) as {
          ensureDbReady?: () => Promise<void>;
        };
        if (typeof mod.ensureDbReady === "function") {
          await mod.ensureDbReady();
        }
      } catch (err) {
        console.error("[app-builder] DB bootstrap failed:", err);
        throw err;
      }
    },
  };
}

function authPopupPlugin(): Plugin {
  return {
    name: "app-builder:auth-popup",
    apply: "serve",
    configureServer(server) {
      server.middlewares.use(async (req, res, next) => {
        try {
          const rawUrl = req.url ?? "";
          const pathOnly = rawUrl.split("?", 1)[0] ?? "";
          if (pathOnly !== "/auth/popup") {
            next();
            return;
          }
          if ((req.method ?? "GET").toUpperCase() !== "GET") {
            res.statusCode = 405;
            res.setHeader("content-type", "text/plain; charset=utf-8");
            res.end("Method Not Allowed");
            return;
          }
          const host = String(req.headers["x-forwarded-host"] ?? req.headers.host ?? "localhost:8080");
          const proto = String(
            req.headers["x-forwarded-proto"] ??
              ((req.socket as { encrypted?: boolean } | undefined)?.encrypted ? "https" : "http"),
          );
          const requestHeaders = new Headers();
          for (const [key, value] of Object.entries(req.headers)) {
            if (value === undefined) continue;
            if (Array.isArray(value)) for (const v of value) requestHeaders.append(key, v);
            else requestHeaders.set(key, value);
          }
          if (!requestHeaders.has("host")) requestHeaders.set("host", host);
          const request = new Request(`${proto}://${host}${rawUrl}`, { method: "GET", headers: requestHeaders });
          const mod = (await server.ssrLoadModule("/src/lib/auth/popup.server.ts")) as {
            handleAuthPopupRequest: (req: Request) => Promise<Response>;
          };
          const response = await mod.handleAuthPopupRequest(request);
          res.statusCode = response.status;
          const setCookies =
            typeof response.headers.getSetCookie === "function" ? response.headers.getSetCookie() : [];
          response.headers.forEach((value, key) => {
            if (key.toLowerCase() === "set-cookie") return;
            res.setHeader(key, value);
          });
          for (const cookie of setCookies) res.appendHeader("set-cookie", cookie);
          res.end(Buffer.from(await response.arrayBuffer()));
        } catch (err) {
          console.error("[app-builder] /auth/popup handler failed:", err);
          if (!res.headersSent) {
            res.statusCode = 500;
            res.setHeader("content-type", "text/plain; charset=utf-8");
            res.end("auth popup failed");
          }
        }
      });
    },
  };
}

const NATIVE_MIME: Record<string, string> = {
  apk: "application/vnd.android.package-archive",
  exe: "application/vnd.microsoft.portable-executable",
  dmg: "application/x-apple-diskimage",
  AppImage: "application/octet-stream",
  zip: "application/zip",
};

const NATIVE_PACKS = new Set([
  "KhmerCalendar.apk",
  "KhmerCalendar.exe",
  "KhmerCalendar.dmg",
  "KhmerCalendar.AppImage",
  "KhmerCalendar-project.zip",
]);

function nativePackMiddleware(root: string) {
  return (req: IncomingMessage, res: ServerResponse, next: () => void) => {
    const urlPath = decodeURIComponent((req.url ?? "").split("?")[0] ?? "");
    const hit = urlPath.match(/^\/native\/([^/]+)\$/);
    if (!hit) {
      next();
      return;
    }
    const name = hit[1] ?? "";
    if (!name || name.includes("..") || name.includes("\\")) {
      res.statusCode = 400;
      res.setHeader("Content-Type", "text/plain; charset=utf-8");
      res.end("bad pack name");
      return;
    }
    const ext = name.includes(".") ? name.slice(name.lastIndexOf(".") + 1) : "";
    const type = NATIVE_MIME[ext] ?? "application/octet-stream";
    const file = join(root, "public", "native", name);
    try {
      const st = statSync(file);
      if (!st.isFile()) throw new Error("not file");
      res.statusCode = 200;
      res.setHeader("Content-Type", type);
      res.setHeader("Content-Length", String(st.size));
      res.setHeader("Content-Disposition", `attachment; filename="${name}"`);
      res.setHeader("X-Content-Type-Options", "nosniff");
      res.setHeader("Cache-Control", "no-store");
      if ((req.method ?? "GET").toUpperCase() === "HEAD") {
        res.end();
        return;
      }
      createReadStream(file).pipe(res);
    } catch {
      if (NATIVE_PACKS.has(name) || ext in NATIVE_MIME) {
        res.statusCode = 404;
        res.setHeader("Content-Type", "text/plain; charset=utf-8");
        res.end("pack not found");
        return;
      }
      next();
    }
  };
}

function nativeDownloadPlugin(): Plugin {
  return {
    name: "native-download",
    configureServer(server) {
      server.middlewares.use(nativePackMiddleware(server.config.root));
    },
    configurePreviewServer(server) {
      server.middlewares.use(nativePackMiddleware(server.config.root));
    },
  };
}

export default defineConfig(({ command, isPreview }) => ({
  server: {
    host: "0.0.0.0",
    port: 8080,
    strictPort: true,
  },
  preview: {
    host: "127.0.0.1",
    port: 8081,
    strictPort: true,
  },
  resolve: { tsconfigPaths: true },
  plugins: [
    pgliteBootstrapPlugin(),
    authPopupPlugin(),
    nativeDownloadPlugin(),
    appEnvPlugin(),
    appPwaPlugin(),
    tailwindcss(),
    tanstackStart(),
    ...(command === "build" || isPreview
      ? [
          nitro({
            preset: "vercel",
            serverDir: "./server",
            routeRules: {
              "/native/**": {
                headers: {
                  "X-Content-Type-Options": "nosniff",
                  "Cache-Control": "no-store",
                  "Content-Disposition": "attachment",
                },
              },
            },
          }),
        ]
      : []),
    viteReact(),
  ],
}));
