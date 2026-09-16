import { useEffect, useRef, useState } from "react";
import { t, type Lang } from "../lib/i18n";
import { loadMaterial, materialReady } from "../lib/material";

type Asset = { href: string; name: string; kind: "font" | "image" | "module"; family?: string; weight?: string };

const FONTS: Asset[] = [
  ["kantumruy-pro-khmer-400-normal.woff2", "Kantumruy Pro", "400"],
  ["kantumruy-pro-latin-400-normal.woff2", "Kantumruy Pro", "400"],
  ["kantumruy-pro-khmer-500-normal.woff2", "Kantumruy Pro", "500"],
  ["kantumruy-pro-latin-500-normal.woff2", "Kantumruy Pro", "500"],
  ["kantumruy-pro-khmer-600-normal.woff2", "Kantumruy Pro", "600"],
  ["kantumruy-pro-latin-600-normal.woff2", "Kantumruy Pro", "600"],
  ["kantumruy-pro-khmer-700-normal.woff2", "Kantumruy Pro", "700"],
  ["kantumruy-pro-latin-700-normal.woff2", "Kantumruy Pro", "700"],
  ["noto-sans-khmer-khmer-400-normal.woff2", "Noto Sans Khmer", "400"],
  ["noto-sans-khmer-khmer-500-normal.woff2", "Noto Sans Khmer", "500"],
  ["noto-sans-khmer-khmer-600-normal.woff2", "Noto Sans Khmer", "600"],
  ["noto-sans-khmer-khmer-700-normal.woff2", "Noto Sans Khmer", "700"],
].map(([file, family, weight]) => ({
  href: `/fonts/${file}`,
  name: `fonts/${file}`,
  kind: "font" as const,
  family,
  weight,
}));

const IMAGES: Asset[] = `/icon-512.png,/icon-192.png,/apple-touch-icon.png,/favicon.svg,/og.jpg,/weather/phnom-penh.jpg,/weather/phnom-penh-alt.jpg,/weather/siem-reap.jpg,/weather/battambang.jpg,/weather/kampot.jpg,/weather/kampot-river.jpg,/weather/sihanoukville.jpg,/weather/kampong-cham.jpg,/weather/kratie.jpg,/weather/mondulkiri.jpg,/weather/preah-vihear.jpg,/weather/banteay.jpg,/zodiac/svg/rat.svg,/zodiac/svg/ox.svg,/zodiac/svg/tiger.svg,/zodiac/svg/rabbit.svg,/zodiac/svg/dragon.svg,/zodiac/svg/snake.svg,/zodiac/svg/horse.svg,/zodiac/svg/goat.svg,/zodiac/svg/monkey.svg,/zodiac/svg/rooster.svg,/zodiac/svg/dog.svg,/zodiac/svg/pig.svg`
  .split(",")
  .map((href) => ({ href, name: href.replace(/^\//, ""), kind: "image" as const }));

const EXTRA: Asset[] = [
  { href: "/material-symbols.woff2", name: "material-symbols.woff2", kind: "font", family: "Material Symbols Outlined", weight: "400" },
  { href: "material-web", name: "@material/web", kind: "module" },
];

const ALL = [...FONTS, ...IMAGES, ...EXTRA];
const MIN_MS = 720;
const MAX_MS = 8000;
const CACHE = "khmer-calendar-boot-v1";

async function warmFont(a: Asset) {
  if (!a.family || !document.fonts?.load) return;
  await document.fonts.load(`${a.weight ?? "400"} 48px "${a.family}"`).catch(() => undefined);
}

async function withTimeout<T>(p: Promise<T>, ms: number) {
  let id = 0;
  try {
    return await Promise.race([
      p,
      new Promise<T>((_, reject) => {
        id = window.setTimeout(() => reject(new Error("timeout")), ms);
      }),
    ]);
  } finally {
    window.clearTimeout(id);
  }
}

async function loadOne(a: Asset) {
  if (a.kind === "module") {
    await withTimeout(loadMaterial(), 4000).catch(() => undefined);
    return;
  }
  if (a.kind === "font" && a.family && document.fonts?.check?.(`${a.weight ?? "400"} 48px "${a.family}"`)) {
    return;
  }
  try {
    if (typeof caches !== "undefined") {
      const hit = await withTimeout(
        caches.match(new URL(a.href, location.origin).href, { ignoreSearch: true }),
        400,
      );
      if (hit) {
        if (a.kind === "font") await warmFont(a);
        return;
      }
    }
  } catch {
    /* ignore */
  }
  try {
    const res = await withTimeout(
      fetch(a.href, { credentials: "same-origin", cache: "force-cache" }),
      1200,
    );
    if (res?.ok && typeof caches !== "undefined") {
      try {
        await (await caches.open(CACHE)).put(new URL(a.href, location.origin).href, res.clone());
      } catch {
        /* ignore */
      }
    }
  } catch {
    /* ignore */
  }
  if (a.kind === "font") {
    await warmFont(a);
    return;
  }
  if (a.kind === "image") {
    await withTimeout(
      new Promise<void>((resolve) => {
        const img = new Image();
        img.decoding = "async";
        img.onload = () => resolve();
        img.onerror = () => resolve();
        img.src = a.href;
      }),
      1200,
    ).catch(() => undefined);
  }
}

async function bootAll(on: (p: { percent: number; name: string }) => void) {
  const total = ALL.length;
  let loaded = 0;
  const pending: Asset[] = [];
  for (const a of ALL) {
    if (a.kind === "module" && materialReady()) {
      loaded += 1;
      continue;
    }
    if (a.kind === "font" && a.family && document.fonts?.check?.(`${a.weight ?? "400"} 48px "${a.family}"`)) {
      loaded += 1;
      continue;
    }
    pending.push(a);
  }
  if (pending.length === 0) {
    if (!materialReady()) await loadMaterial();
    on({ percent: 100, name: "" });
    return;
  }
  on({ percent: Math.round((loaded / total) * 100), name: pending[0]?.name ?? "" });
  for (const a of pending) {
    on({ percent: Math.round((loaded / total) * 100), name: a.name });
    try {
      await loadOne(a);
    } catch {
      /* keep going */
    }
    loaded += 1;
    on({ percent: Math.round((loaded / total) * 100), name: a.name });
  }
  on({ percent: 100, name: pending.at(-1)?.name ?? "" });
}

export function BootSplash({ lang = "km", onDone }: { lang?: Lang; onDone?: () => void }) {
  const [pct, setPct] = useState(0);
  const [file, setFile] = useState("");
  const done = useRef(onDone);
  done.current = onDone;

  useEffect(() => {
    document.documentElement.classList.add("is-booting");
    setPct(4);
    const start = Date.now();
    let dead = false;
    const cap = new Promise<void>((resolve) => {
      window.setTimeout(() => {
        if (!dead) {
          setPct(100);
          setFile("");
        }
        resolve();
      }, MAX_MS);
    });
    Promise.race([
      bootAll((p) => {
        if (dead) return;
        setPct(p.percent);
        setFile(p.name);
      }).catch(() => undefined),
      cap,
    ]).then(async () => {
      const wait = MIN_MS - (Date.now() - start);
      if (wait > 0) await new Promise((r) => window.setTimeout(r, wait));
      if (!dead) done.current?.();
    });
    return () => {
      dead = true;
    };
  }, []);

  return (
    <div className="boot-splash" role="status" aria-live="polite" aria-label={t(lang, "loading")}>
      <div className="boot-splash-blob boot-splash-blob-a" aria-hidden="true" />
      <div className="boot-splash-blob boot-splash-blob-b" aria-hidden="true" />
      <div className="boot-splash-main">
        <div className="boot-splash-logo-wrap">
          <img className="boot-splash-logo" src="/icon-512.png" width={112} height={112} alt="" />
        </div>
        <h1 className="boot-splash-name">{t(lang, "appName")}</h1>
        <p className="boot-splash-tag">{t(lang, "splashTag")}</p>
        <div className="boot-splash-bar" aria-hidden="true">
          <span className="boot-splash-bar-fill" style={{ width: `${pct}%` }} />
        </div>
        <p className="boot-splash-file">{file}</p>
        <p className="boot-splash-pct">{pct}%</p>
      </div>
      <p className="boot-splash-ver">Version 1.0.0</p>
    </div>
  );
}
