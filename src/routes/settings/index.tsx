import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useStore } from "../../lib/store";
import { t } from "../../lib/i18n";
import { ActionRow, LangRadios, LinkRow, SetGroup, SubHead, isPackaged } from "../../components/settings-ui";
import { Dialog } from "../../components/dialog";
import { Ripple } from "../../components/ripple";
import { weekdaysFull } from "../../lib/i18n";

export const Route = createFileRoute("/settings/")({ component: SettingsHome });

function SettingsHome() {
  const lang = useStore((s) => s.lang);
  const pref = useStore((s) => s.langPref);
  const setLang = useStore((s) => s.setLang);
  const weekStartsOn = useStore((s) => s.weekStartsOn);
  const setWeekStartsOn = useStore((s) => s.setWeekStartsOn);
  const installed = useStore((s) => s.installed);
  const [langOpen, setLangOpen] = useState(false);
  const [weekOpen, setWeekOpen] = useState(false);
  const days = weekdaysFull(lang);
  const weekLabel = days[weekStartsOn];
  return (
    <div className="more-layout set-page">
      <SubHead title={t(lang, "settingsTitle")} backTo="/more" />
      <SetGroup>
        <LinkRow icon="palette" title={t(lang, "themePageTitle")} subtitle={t(lang, "themePageSub")} to="/settings/theme" />
        <ActionRow
          icon="translate"
          title={t(lang, "language")}
          subtitle={pref === "auto" ? t(lang, "langAuto") : pref === "km" ? "ខ្មែរ" : "English"}
          trailing="chevron_right"
          onClick={() => setLangOpen(true)}
        />
        <ActionRow
          icon="view_week"
          title={t(lang, "weekStartsOn")}
          subtitle={weekLabel}
          trailing="chevron_right"
          onClick={() => setWeekOpen(true)}
        />
        <LinkRow icon="verified_user" title={t(lang, "privacyTitle")} subtitle={t(lang, "privacySub")} to="/settings/privacyandpermission" />
        <LinkRow icon="delete_sweep" title={t(lang, "clearTitle")} subtitle={t(lang, "clearSub")} to="/settings/clear" />
        {isPackaged() || installed ? null : (
          <LinkRow icon="install_mobile" title={t(lang, "installerTitle")} subtitle={t(lang, "installerSub")} to="/download" />
        )}
      </SetGroup>
      <Dialog open={langOpen} title={t(lang, "languageTitle")} onClose={() => setLangOpen(false)}>
        <LangRadios
          value={pref}
          uiLang={lang}
          name="app-lang"
          onPick={(v) => {
            setLang(v);
            setLangOpen(false);
          }}
        />
      </Dialog>
      <Dialog open={weekOpen} title={t(lang, "weekStartsOn")} onClose={() => setWeekOpen(false)}>
        <div className="lang-opts" role="radiogroup">
          {([0, 1, 6] as const).map((d) => (
            <label
              key={d}
              className={`lang-opt has-ripple ${weekStartsOn === d ? "is-on" : ""}`}
              onClick={() => {
                setWeekStartsOn(d);
                setWeekOpen(false);
              }}
            >
              <Ripple />
              <md-radio
                name="week-start"
                checked={weekStartsOn === d || undefined}
                onClick={() => {
                  setWeekStartsOn(d);
                  setWeekOpen(false);
                }}
              />
              <span className="lang-opt-copy">
                <span className="lang-opt-title">{days[d]}</span>
              </span>
            </label>
          ))}
        </div>
      </Dialog>
    </div>
  );
}
