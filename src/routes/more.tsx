import { createFileRoute } from "@tanstack/react-router";
import { useStore } from "../lib/store";
import { t } from "../lib/i18n";
import { LinkRow, SetGroup, isPackaged } from "../components/settings-ui";

export const Route = createFileRoute("/more")({ component: MorePage });

function MorePage() {
  const lang = useStore((s) => s.lang);
  const installed = useStore((s) => s.installed);
  return (
    <section className="tab-page">
      <div className="more-layout set-page is-hub">
        <h1 className="sub-head-title is-root">{t(lang, "moreTitle")}</h1>
        <SetGroup>
          <LinkRow icon="settings" title={t(lang, "settingsTitle")} subtitle={t(lang, "settingsSub")} to="/settings" />
          <LinkRow icon="build" title={t(lang, "toolsTitle")} subtitle={t(lang, "toolsPageSub")} to="/tools" />
        </SetGroup>
        {isPackaged() || installed ? null : (
          <SetGroup>
            <LinkRow icon="install_mobile" title={t(lang, "installerTitle")} subtitle={t(lang, "installerSub")} to="/download" />
          </SetGroup>
        )}
      </div>
    </section>
  );
}
