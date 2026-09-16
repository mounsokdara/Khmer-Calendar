export type ColorSchemeId =
  | "rose"
  | "purple"
  | "slate"
  | "teal"
  | "green"
  | "violet"
  | "magenta"
  | "burgundy"
  | "brown"
  | "amber"
  | "forest"
  | "olive"
  | "navy"
  | "coral";

type TokenMap = Record<string, string>;

/** APK `my` */
function hueFromHex(hex: string): number {
  const t = hex.replace("#", "").padEnd(6, "0");
  const n = Number.parseInt(t.slice(0, 6), 16);
  const r = ((n >> 16) & 255) / 255;
  const g = ((n >> 8) & 255) / 255;
  const b = (n & 255) / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  if (max === min) return 0;
  const c = max - min;
  let h = 0;
  if (max === r) h = ((g - b) / c) % 6;
  else if (max === g) h = (b - r) / c + 2;
  else h = (r - g) / c + 4;
  h *= 60;
  return h < 0 ? h + 360 : h;
}

/** APK `py` — HSL to hex, not CSS hsl(). */
function py(h: number, s: number, l: number): string {
  const sat = s / 100;
  const lit = l / 100;
  const a = sat * Math.min(lit, 1 - lit);
  const f = (n: number) => {
    const k = (n + h / 30) % 12;
    const v = lit - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
    return Math.round(255 * v)
      .toString(16)
      .padStart(2, "0");
  };
  return `#${f(0)}${f(8)}${f(4)}`;
}

/** APK `hy` */
function chip(id: ColorSchemeId, label: string, circle: string) {
  const hue = hueFromHex(circle);
  return {
    id,
    hue,
    label,
    circle,
    top: py(hue, 16, 94),
    bot: py((hue + 16) % 360, 34, 80),
    glow: circle,
  };
}

export const SCHEMES = [
  chip("rose", "ក្រហម", "#9a3b38"),
  chip("purple", "ស្វាយ", "#68509f"),
  chip("slate", "ខៀវ", "#38618d"),
  chip("teal", "បៃតងខៀវ", "#146781"),
  chip("green", "បៃតង", "#036a62"),
  chip("violet", "វីយ៉ូឡែត", "#68548e"),
  chip("magenta", "ផ្កាឈូក", "#7c4e7e"),
  chip("burgundy", "ក្រហមចាស់", "#8c4a61"),
  chip("brown", "ត្នោត", "#8e4d33"),
  chip("amber", "ទឹកក្រូច", "#84541a"),
  chip("forest", "ព្រៃ", "#40693f"),
  chip("olive", "អូលីវ", "#586424"),
  chip("navy", "ទឹកប៊ិច", "#3d4c7a"),
  chip("coral", "ថ្មប៉ប្រះទឹក", "#c45c4a"),
] as const;

/** APK `xy` */
const ROSE_LIGHT: TokenMap = {
  "--md-sys-color-primary": "#9a3b38",
  "--md-sys-color-on-primary": "#ffffff",
  "--md-sys-color-primary-container": "#ffdad6",
  "--md-sys-color-on-primary-container": "#410003",
  "--md-sys-color-secondary": "#775652",
  "--md-sys-color-on-secondary": "#ffffff",
  "--md-sys-color-secondary-container": "#ffdad6",
  "--md-sys-color-on-secondary-container": "#2c1512",
  "--md-sys-color-tertiary": "#1b7a6e",
  "--md-sys-color-on-tertiary": "#ffffff",
  "--md-sys-color-tertiary-container": "#c5ebe3",
  "--md-sys-color-on-tertiary-container": "#00201c",
  "--md-sys-color-surface": "#fffbff",
  "--md-sys-color-on-surface": "#2b1b1a",
  "--md-sys-color-surface-variant": "#f5ddda",
  "--md-sys-color-on-surface-variant": "#5d403c",
  "--md-sys-color-surface-container-lowest": "#ffffff",
  "--md-sys-color-surface-container-low": "#fff1ef",
  "--md-sys-color-surface-container": "#f8edeb",
  "--md-sys-color-surface-container-high": "#f3e7e5",
  "--md-sys-color-surface-container-highest": "#ede0de",
  "--md-sys-color-outline": "#926f6b",
  "--md-sys-color-outline-variant": "#e7beba",
  "--md-sys-color-inverse-surface": "#412e2c",
  "--md-sys-color-inverse-on-surface": "#fceeea",
  "--md-sys-color-inverse-primary": "#ffb3ad",
};

/** APK `Sy` */
const ROSE_DARK: TokenMap = {
  "--md-sys-color-primary": "#ffb3ad",
  "--md-sys-color-on-primary": "#5f1413",
  "--md-sys-color-primary-container": "#7c2a27",
  "--md-sys-color-on-primary-container": "#ffdad6",
  "--md-sys-color-secondary": "#e7bdb7",
  "--md-sys-color-on-secondary": "#442926",
  "--md-sys-color-secondary-container": "#5d3f3b",
  "--md-sys-color-on-secondary-container": "#ffdad6",
  "--md-sys-color-tertiary": "#a9cfc7",
  "--md-sys-color-on-tertiary": "#003731",
  "--md-sys-color-tertiary-container": "#0b534a",
  "--md-sys-color-on-tertiary-container": "#c5ebe3",
  "--md-sys-color-surface": "#1c1110",
  "--md-sys-color-on-surface": "#f6ddda",
  "--md-sys-color-surface-variant": "#5d403c",
  "--md-sys-color-on-surface-variant": "#e7beba",
  "--md-sys-color-surface-container-lowest": "#160c0b",
  "--md-sys-color-surface-container-low": "#251817",
  "--md-sys-color-surface-container": "#2a1c1b",
  "--md-sys-color-surface-container-high": "#352625",
  "--md-sys-color-surface-container-highest": "#41312f",
  "--md-sys-color-outline": "#ad8985",
  "--md-sys-color-outline-variant": "#5d403c",
  "--md-sys-color-inverse-surface": "#f6ddda",
  "--md-sys-color-inverse-on-surface": "#412e2c",
  "--md-sys-color-inverse-primary": "#9a3b38",
};

/** APK `Cy` */
function Cy(hex: string, hue: number, dark: boolean): TokenMap {
  const i = (hue + 145) % 360;
  if (dark) {
    return {
      "--md-sys-color-primary": py(hue, 72, 82),
      "--md-sys-color-on-primary": py(hue, 40, 18),
      "--md-sys-color-primary-container": py(hue, 32, 28),
      "--md-sys-color-on-primary-container": py(hue, 78, 90),
      "--md-sys-color-secondary": py(hue, 28, 80),
      "--md-sys-color-on-secondary": py(hue, 22, 18),
      "--md-sys-color-secondary-container": py(hue, 18, 26),
      "--md-sys-color-on-secondary-container": py(hue, 50, 90),
      "--md-sys-color-tertiary": py(i, 42, 78),
      "--md-sys-color-on-tertiary": py(i, 40, 14),
      "--md-sys-color-tertiary-container": py(i, 28, 22),
      "--md-sys-color-on-tertiary-container": py(i, 50, 88),
      "--md-sys-color-surface": py(hue, 14, 10),
      "--md-sys-color-on-surface": py(hue, 22, 92),
      "--md-sys-color-surface-variant": py(hue, 14, 28),
      "--md-sys-color-on-surface-variant": py(hue, 18, 78),
      "--md-sys-color-surface-container-lowest": py(hue, 16, 7),
      "--md-sys-color-surface-container-low": py(hue, 12, 13),
      "--md-sys-color-surface-container": py(hue, 12, 16),
      "--md-sys-color-surface-container-high": py(hue, 12, 20),
      "--md-sys-color-surface-container-highest": py(hue, 12, 24),
      "--md-sys-color-outline": py(hue, 14, 60),
      "--md-sys-color-outline-variant": py(hue, 14, 28),
      "--md-sys-color-inverse-surface": py(hue, 22, 92),
      "--md-sys-color-inverse-on-surface": py(hue, 18, 22),
      "--md-sys-color-inverse-primary": hex,
    };
  }
  return {
    "--md-sys-color-primary": hex,
    "--md-sys-color-on-primary": "#ffffff",
    "--md-sys-color-primary-container": py(hue, 82, 90),
    "--md-sys-color-on-primary-container": py(hue, 42, 16),
    "--md-sys-color-secondary": py(hue, 22, 40),
    "--md-sys-color-on-secondary": "#ffffff",
    "--md-sys-color-secondary-container": py(hue, 48, 90),
    "--md-sys-color-on-secondary-container": py(hue, 26, 16),
    "--md-sys-color-tertiary": py(i, 48, 32),
    "--md-sys-color-on-tertiary": "#ffffff",
    "--md-sys-color-tertiary-container": py(i, 50, 88),
    "--md-sys-color-on-tertiary-container": py(i, 40, 12),
    "--md-sys-color-surface": py(hue, 40, 99),
    "--md-sys-color-on-surface": py(hue, 18, 14),
    "--md-sys-color-surface-variant": py(hue, 28, 90),
    "--md-sys-color-on-surface-variant": py(hue, 16, 32),
    "--md-sys-color-surface-container-lowest": "#ffffff",
    "--md-sys-color-surface-container-low": py(hue, 50, 96.5),
    "--md-sys-color-surface-container": py(hue, 36, 94),
    "--md-sys-color-surface-container-high": py(hue, 30, 92),
    "--md-sys-color-surface-container-highest": py(hue, 24, 90),
    "--md-sys-color-outline": py(hue, 16, 50),
    "--md-sys-color-outline-variant": py(hue, 22, 80),
    "--md-sys-color-inverse-surface": py(hue, 18, 22),
    "--md-sys-color-inverse-on-surface": py(hue, 30, 94),
    "--md-sys-color-inverse-primary": py(hue, 70, 80),
  };
}

/** APK `wy` */
function wy(tokens: TokenMap, hue: number): TokenMap {
  return {
    ...tokens,
    "--md-sys-color-surface": "#000000",
    "--md-sys-color-surface-container-lowest": "#000000",
    "--md-sys-color-surface-container-low": py(hue, 10, 5),
    "--md-sys-color-surface-container": py(hue, 10, 8),
    "--md-sys-color-surface-container-high": py(hue, 10, 12),
    "--md-sys-color-surface-container-highest": py(hue, 10, 16),
  };
}

function prefersDark() {
  if (typeof window === "undefined") return false;
  return window.matchMedia?.("(prefers-color-scheme: dark)").matches;
}

/** APK `Ey` */
function resolveMode(theme: "light" | "dark" | "system"): "light" | "dark" {
  if (theme === "system") return prefersDark() ? "dark" : "light";
  return theme;
}

/** APK `Ty` */
function Ty(id: ColorSchemeId, mode: "light" | "dark", extraDark: boolean): TokenMap {
  const scheme = SCHEMES.find((s) => s.id === id) ?? SCHEMES[0];
  const base =
    id === "rose" ? (mode === "dark" ? { ...ROSE_DARK } : { ...ROSE_LIGHT }) : Cy(scheme.circle, scheme.hue, mode === "dark");
  return extraDark && mode === "dark" ? wy(base, scheme.hue) : base;
}

/** APK light surface is L=99; picker preview uses the same. */
export function surfaceFromHex(hex: string, dark: boolean): string {
  const hue = hueFromHex(hex || "#9a3b38");
  return dark ? py(hue, 14, 10) : py(hue, 40, 99);
}

/**
 * APK `Dy`.
 * Material You on → scheme palette. Off → rose tokens; accent/highlight stay on --cal-*.
 * `--md-sys-color-background` aliases surface so Material Web screen tokens match the APK.
 */
export function applyTheme(opts: {
  theme: "light" | "dark" | "system";
  colorScheme: ColorSchemeId;
  materialYou: boolean;
  extraDark: boolean;
  accentColor: string;
  highlightColor: string;
  highlightAlpha: number;
}) {
  if (typeof document === "undefined") return;
  const mode = resolveMode(opts.theme);
  const dark = mode === "dark";
  const schemeId = opts.materialYou ? opts.colorScheme : "rose";
  const tokens = Ty(schemeId, mode, opts.extraDark);
  const surface = tokens["--md-sys-color-surface"] ?? "#fffbff";
  const onSurface = tokens["--md-sys-color-on-surface"] ?? "#2b1b1a";
  const root = document.documentElement;
  root.removeAttribute("data-shape");
  root.classList.toggle("dark", dark);
  root.classList.toggle("extra-dark", opts.extraDark && dark);
  root.dataset.theme = mode;
  root.dataset.scheme = schemeId;
  root.style.colorScheme = mode;
  for (const [key, value] of Object.entries(tokens)) root.style.setProperty(key, value);
  root.style.setProperty("--md-sys-color-background", surface);
  root.style.setProperty("--md-sys-color-on-background", onSurface);
  if (opts.materialYou) {
    const primary = tokens["--md-sys-color-primary"] ?? "#9a3b38";
    root.style.setProperty("--cal-accent", primary);
    root.style.setProperty("--cal-highlight", primary);
    root.style.setProperty("--cal-highlight-alpha", "0");
  } else {
    root.style.setProperty("--cal-accent", opts.accentColor || "#F5C400");
    root.style.setProperty("--cal-highlight", opts.highlightColor || "#FF3B30");
    root.style.setProperty("--cal-highlight-alpha", String(opts.highlightAlpha ?? 0.22));
  }
  const primary = tokens["--md-sys-color-primary"] ?? "#9a3b38";
  root.style.setProperty("--color-primary", primary);
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) meta.setAttribute("content", primary);
  const schemeMeta = document.querySelector('meta[name="color-scheme"]');
  if (schemeMeta) schemeMeta.setAttribute("content", opts.theme === "system" ? "light dark" : mode);
  if (!document.startViewTransition) root.classList.add("no-vt");
  else root.classList.remove("no-vt");
}
