import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useStore } from "../lib/store";
import { t } from "../lib/i18n";
import { ActionRow, SetGroup, SubHead, isPackaged } from "../components/settings-ui";
import { Dialog, DlgBtn } from "../components/dialog";
import { StackBar } from "../components/stack-bar";
import { PACKS, savePack } from "../lib/packs";

export const Route = createFileRoute("/download")({ component: DownloadPage });

function DownloadPage() {
  const lang = useStore((s) => s.lang);
  const setInstalled = useStore((s) => s.setInstalled);
  const [shortcut, setShortcut] = useState(false);
  const [toast, setToast] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  async function save(file: string, name: string) {
    try {
      await savePack(file, name);
      setToast(t(lang, "exportLogReady"));
    } catch {
      setErr(t(lang, "exportFail"));
    }
  }

  async function installBrowser() {
    const ev = (window as Window & { deferredPrompt?: { prompt: () => Promise<void> } }).deferredPrompt;
    if (ev) {
      await ev.prompt();
      setInstalled(true);
      setShortcut(false);
      return;
    }
    setShortcut(true);
  }

  if (isPackaged()) {
    return (
      <section className="tab-page overlay-page">
        <div className="more-layout set-page">
          <SubHead title={t(lang, "downloadTitle")} backTo="/more" />
          <p className="sub-lead">{t(lang, "exportInstalled")}</p>
        </div>
      </section>
    );
  }

  return (
    <section className="tab-page overlay-page">
      <div className="more-layout set-page">
        <SubHead title={t(lang, "downloadTitle")} backTo="/more" />
        <p className="sub-lead">{t(lang, "downloadSub")}</p>
        <SetGroup>
          <ActionRow
            icon="install_mobile"
            title={t(lang, "exportBrowser")}
            subtitle={t(lang, "exportBrowserSub")}
            onClick={() => void installBrowser()}
            trailing="chevron_right"
          />
        </SetGroup>
        <SetGroup>
          {PACKS.map((p) => (
            <ActionRow
              key={p.id}
              icon={p.icon}
              title={t(lang, p.titleKey)}
              subtitle={t(lang, p.subKey)}
              trailing="download"
              onClick={() => void save(p.file, p.name)}
            />
          ))}
        </SetGroup>
      </div>
      <Dialog
        open={shortcut}
        title={t(lang, "shortcutTitle")}
        onClose={() => setShortcut(false)}
        actions={
          <>
            <DlgBtn secondary onClick={() => setShortcut(false)}>
              {t(lang, "cancel")}
            </DlgBtn>
            <DlgBtn
              onClick={() => {
                setInstalled(true);
                setShortcut(false);
              }}
            >
              {t(lang, "shortcutAdd")}
            </DlgBtn>
          </>
        }
      >
        <p>{t(lang, "shortcutAsk")}</p>
        <p className="calc-sub">{t(lang, "shortcutAndroid")}</p>
        <p className="calc-sub">{t(lang, "shortcutIos")}</p>
        <p className="calc-sub">{t(lang, "shortcutDesktop")}</p>
      </Dialog>
      <Dialog open={!!err} title={t(lang, "exportFail")} onClose={() => setErr(null)} actions={<DlgBtn onClick={() => setErr(null)}>{t(lang, "ok")}</DlgBtn>}>
        <p>{err}</p>
      </Dialog>
      <StackBar open={!!toast} message={toast ?? ""} onDismiss={() => setToast(null)} />
    </section>
  );
}
