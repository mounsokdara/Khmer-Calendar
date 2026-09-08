import { useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { t, type Lang, type LangPref } from "../lib/i18n";
import { Icon } from "./icon";
import { Dialog, DlgBtn } from "./dialog";
import { goPage } from "../lib/nav";
import { MdSwitch, MdIconBtn } from "./md-click";
import { Ripple } from "./ripple";
import { useStore } from "../lib/store";

export function isPackaged() {
  if (typeof window === "undefined") return false;
  const w = window as Window & { __KHMER_PACKAGED?: boolean; KhmerNative?: unknown };
  return !!(w.__KHMER_PACKAGED || w.KhmerNative);
}

export function deviceKind(): "android" | "windows" | "macos" | "linux" | "ios" | "other" {
  if (typeof navigator === "undefined") return "other";
  const ua = navigator.userAgent || "";
  const p = navigator.platform || "";
  if (/iPhone|iPad|iPod/i.test(ua) || (p === "MacIntel" && (navigator.maxTouchPoints || 0) > 1)) return "ios";
  if (/Android/i.test(ua)) return "android";
  if (/Win/i.test(p) || /Windows NT/i.test(ua)) return "windows";
  if (/Mac/i.test(p) || /Macintosh/i.test(ua)) return "macos";
  if (/Linux/i.test(ua) || /Linux/i.test(p)) return "linux";
  return "other";
}

export function packFor(kind: ReturnType<typeof deviceKind>) {
  return kind === "android" || kind === "windows" || kind === "macos" || kind === "linux" ? kind : null;
}

export { goPage };

export function SubHead({ title, backTo }: { title: string; backTo: string }) {
  const nav = useNavigate();
  const lang = useStore((s) => s.lang);
  return (
    <header className="sub-head">
      <MdIconBtn className="icon-btn sub-head-back" ariaLabel={t(lang, "back")} onClick={() => goPage(nav, backTo, "back")}>
        <Icon name="arrow_back" />
      </MdIconBtn>
      <h1 className="sub-head-title">{title}</h1>
    </header>
  );
}

export function SetGroup({ children }: { children: React.ReactNode }) {
  return <div className="set-group">{children}</div>;
}

export function ToggleRow({
  icon,
  title,
  subtitle,
  checked,
  onToggle,
  danger,
}: {
  icon?: string;
  title: string;
  subtitle?: string;
  checked: boolean;
  onToggle: () => void;
  danger?: boolean;
}) {
  return (
    <button
      type="button"
      className={`set-row has-ripple ${!icon ? "is-bare" : ""} ${danger ? "is-danger" : ""}`}
      role="switch"
      aria-checked={checked}
      onClick={(e) => {
        if ((e.target as HTMLElement).closest("md-switch")) return;
        onToggle();
      }}
    >
      <Ripple />
      {icon ? <Icon name={icon} className="set-row-icon" filled /> : null}
      <span className="theme-toggle-copy">
        <span className="theme-toggle-title">{title}</span>
        {subtitle ? <span className="theme-toggle-sub">{subtitle}</span> : null}
      </span>
      <MdSwitch selected={checked} onChange={onToggle} ariaLabel={title} />
    </button>
  );
}

export function LinkRow({
  icon,
  title,
  subtitle,
  to,
  danger,
}: {
  icon: string;
  title: string;
  subtitle?: string;
  to: string;
  danger?: boolean;
}) {
  const nav = useNavigate();
  return (
    <button type="button" className={`set-row has-ripple ${danger ? "is-danger" : ""}`} onClick={() => goPage(nav, to, "fwd")}>
      <Ripple />
      <Icon name={icon} className="set-row-icon" filled />
      <span className="theme-toggle-copy">
        <span className="theme-toggle-title">{title}</span>
        {subtitle ? <span className="theme-toggle-sub">{subtitle}</span> : null}
      </span>
      <Icon name="chevron_right" className="theme-row-chevron" />
    </button>
  );
}

export function ActionRow({
  icon,
  title,
  subtitle,
  onClick,
  trailing,
  danger,
}: {
  icon: string;
  title: string;
  subtitle?: string;
  onClick: () => void;
  trailing?: string;
  danger?: boolean;
}) {
  return (
    <button type="button" className={`set-row has-ripple ${danger ? "is-danger" : ""}`} onClick={onClick}>
      <Ripple />
      <Icon name={icon} className="set-row-icon" filled />
      <span className="theme-toggle-copy">
        <span className="theme-toggle-title">{title}</span>
        {subtitle ? <span className="theme-toggle-sub">{subtitle}</span> : null}
      </span>
      {trailing ? <Icon name={trailing} className="theme-row-chevron" /> : null}
    </button>
  );
}

export function ColorRow({
  title,
  subtitle,
  value,
  onPick,
  disabled,
}: {
  title: string;
  subtitle?: string;
  value: string;
  onPick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      className={`set-row is-bare has-ripple ${disabled ? "is-disabled" : ""}`}
      onClick={onPick}
      disabled={disabled}
    >
      <Ripple />
      <span className="theme-toggle-copy">
        <span className="theme-toggle-title">{title}</span>
        {subtitle ? <span className="theme-toggle-sub">{subtitle}</span> : null}
      </span>
      <span className="color-swatch" style={{ background: value }} aria-hidden="true" />
    </button>
  );
}

export function LangRadios({
  value,
  name,
  uiLang,
  onPick,
}: {
  value: LangPref;
  name: string;
  uiLang: Lang;
  onPick: (v: LangPref) => void;
}) {
  const opts: { id: LangPref; title: string; sub: string }[] = [
    { id: "auto", title: t(uiLang, "langAuto"), sub: t(uiLang, "langAutoSub") },
    { id: "km", title: "ខ្មែរ", sub: "Khmer" },
    { id: "en", title: "English", sub: "English" },
  ];
  return (
    <div className="lang-opts" role="radiogroup">
      {opts.map((o) => {
        const on = value === o.id;
        return (
          <label key={o.id} className={`lang-opt has-ripple ${on ? "is-on" : ""}`} onClick={() => onPick(o.id)}>
            <Ripple />
            <md-radio
              name={name}
              value={o.id}
              checked={on || undefined}
              touch-target="wrapper"
              onClick={() => onPick(o.id)}
            />
            <span className="lang-opt-copy">
              <span className="lang-opt-title">{o.title}</span>
              <span className="lang-opt-sub">{o.sub}</span>
            </span>
          </label>
        );
      })}
    </div>
  );
}

const PRESETS = ["#F5C400", "#FF3B30", "#FF9500", "#34C759", "#007AFF", "#5856D6", "#AF52DE", "#FF2D55", "#5AC8FA", "#8E8E93", "#1C1C1E", "#9A3B38"];

function hexHue(hex: string) {
  const t = hex.replace("#", "").padEnd(6, "0");
  const n = Number.parseInt(t.slice(0, 6), 16);
  const r = ((n >> 16) & 255) / 255;
  const g = ((n >> 8) & 255) / 255;
  const b = (n & 255) / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  if (max === min) return 0;
  const c = max - min;
  let h = max === r ? ((g - b) / c) % 6 : max === g ? (b - r) / c + 2 : (r - g) / c + 4;
  h *= 60;
  return h < 0 ? h + 360 : h;
}
function hueHex(h: number) {
  const t = ((h % 360) + 360) % 360;
  const ch = (e: number) => {
    const n = (e + t / 30) % 12;
    const r = 0.54 - 0.414 * Math.max(Math.min(n - 3, 9 - n, 1), -1);
    return Math.round(255 * r)
      .toString(16)
      .padStart(2, "0");
  };
  return `#${ch(0)}${ch(8)}${ch(4)}`.toUpperCase();
}

export function ColorPickerDialog({
  lang,
  open,
  title,
  value,
  onClose,
  onSave,
}: {
  lang: Lang;
  open: boolean;
  title: string;
  value: string;
  onClose: () => void;
  onSave: (v: string) => void;
}) {
  const [v, setV] = useState(value);
  useEffect(() => {
    if (open) setV(value);
  }, [open, value]);
  return (
    <Dialog
      open={open}
      title={title}
      onClose={onClose}
      actions={
        <>
          <DlgBtn secondary onClick={onClose}>
            {t(lang, "cancel")}
          </DlgBtn>
          <DlgBtn onClick={() => onSave(v)}>{t(lang, "save")}</DlgBtn>
        </>
      }
    >
      <div className="color-picker">
        <div className="color-picker-preview" style={{ background: v }} />
        <div className="color-picker-presets">
          {PRESETS.map((c) => (
            <button
              key={c}
              type="button"
              className={`color-preset has-ripple ${v.toUpperCase() === c ? "is-on" : ""}`}
              style={{ background: c }}
              aria-label={c}
              aria-pressed={v.toUpperCase() === c}
              onClick={() => setV(c)}
            >
              <Ripple />
            </button>
          ))}
        </div>
        <input
          className="hue-slider"
          type="range"
          min={0}
          max={360}
          value={Math.round(hexHue(v))}
          aria-label={t(lang, "color")}
          onChange={(e) => setV(hueHex(Number(e.target.value)))}
        />
      </div>
    </Dialog>
  );
}
