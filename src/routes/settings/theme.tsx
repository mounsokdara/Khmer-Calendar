import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useStore } from "../../lib/store";
import { t } from "../../lib/i18n";
import { ColorPickerDialog, ColorRow, SubHead, ToggleRow } from "../../components/settings-ui";
import { SCHEMES } from "../../lib/theme";
import { MdSlider } from "../../components/md-click";
import { Ripple } from "../../components/ripple";

export const Route = createFileRoute("/settings/theme")({ component: ThemePage });

function ThemePage() {
  const lang = useStore((s) => s.lang);
  const theme = useStore((s) => s.theme);
  const setTheme = useStore((s) => s.setTheme);
  const scheme = useStore((s) => s.colorScheme);
  const setScheme = useStore((s) => s.setColorScheme);
  const materialYou = useStore((s) => s.materialYou);
  const setMaterialYou = useStore((s) => s.setMaterialYou);
  const extraDark = useStore((s) => s.extraDark);
  const setExtraDark = useStore((s) => s.setExtraDark);
  const accent = useStore((s) => s.accentColor);
  const setAccent = useStore((s) => s.setAccentColor);
  const highlight = useStore((s) => s.highlightColor);
  const setHighlight = useStore((s) => s.setHighlightColor);
  const alpha = useStore((s) => s.highlightAlpha);
  const setAlpha = useStore((s) => s.setHighlightAlpha);
  const [pick, setPick] = useState<"accent" | "highlight" | null>(null);
  const modes = [
    { id: "light" as const, label: t(lang, "modeLight") },
    { id: "dark" as const, label: t(lang, "modeDark") },
    { id: "system" as const, label: t(lang, "modeSystem") },
  ];

  return (
    <div className="more-layout set-page is-theme">
      <SubHead title={t(lang, "themePageTitle")} backTo="/settings" />
      <div className="mode-seg" role="radiogroup">
        {modes.map((m) => (
          <button
            key={m.id}
            type="button"
            role="radio"
            aria-checked={theme === m.id}
            className={`mode-seg-btn has-ripple ${theme === m.id ? "is-on" : ""}`}
            onClick={() => setTheme(m.id)}
          >
            <Ripple />
            {m.label}
          </button>
        ))}
      </div>
      <ToggleRow
        icon="palette"
        title={t(lang, "materialYou")}
        subtitle={t(lang, "materialYouSub")}
        checked={materialYou}
        onToggle={() => setMaterialYou(!materialYou)}
      />
      <div className={`scheme-scroller ${materialYou ? "" : "is-muted"}`} data-h-pan="" role="radiogroup">
        {SCHEMES.map((s) => (
          <button
            key={s.id}
            type="button"
            disabled={!materialYou}
            className={`scheme-chip has-ripple ${scheme === s.id ? "is-selected" : ""}`}
            style={{ "--chip-circle": s.circle, "--chip-top": s.top, "--chip-bot": s.bot, "--chip-glow": s.glow } as React.CSSProperties}
            onClick={() => setScheme(s.id)}
          >
            <Ripple />
            <span className="scheme-chip-blob" />
            <span className="scheme-chip-dot" />
          </button>
        ))}
      </div>
      <ToggleRow
        icon="contrast"
        title={t(lang, "extraDark")}
        subtitle={t(lang, "extraDarkSub")}
        checked={extraDark}
        onToggle={() => setExtraDark(!extraDark)}
      />
      <div className={`theme-custom ${materialYou ? "is-muted" : ""}`}>
        <ColorRow title={t(lang, "accent")} value={accent} disabled={materialYou} onPick={() => setPick("accent")} />
        <ColorRow title={t(lang, "highlight")} value={highlight} disabled={materialYou} onPick={() => setPick("highlight")} />
        <div className="theme-slider-row">
          <span className="theme-toggle-title">{t(lang, "highlightAlpha")}</span>
          <MdSlider
            className="alpha-slider"
            min={0}
            max={100}
            value={Math.round(alpha * 100)}
            disabled={materialYou}
            labeled
            ariaLabel={t(lang, "highlightAlpha")}
            onInput={(n) => setAlpha(n / 100)}
          />
        </div>
      </div>
      <ColorPickerDialog
        lang={lang}
        open={pick !== null}
        title={pick === "highlight" ? t(lang, "highlight") : t(lang, "accent")}
        value={pick === "highlight" ? highlight : accent}
        onClose={() => setPick(null)}
        onSave={(v) => {
          pick === "highlight" ? setHighlight(v) : setAccent(v);
          setPick(null);
        }}
      />
    </div>
  );
}
