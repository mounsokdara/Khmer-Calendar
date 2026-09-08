import { createFileRoute } from "@tanstack/react-router";
import { useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { useStore } from "../lib/store";
import { t } from "../lib/i18n";
import { LangRadios, deviceKind, isPackaged, packFor } from "../components/settings-ui";
import { Icon } from "../components/icon";
import { OsLogo } from "../components/os-logo";
import { Dialog, DlgBtn } from "../components/dialog";
import { MdBtn } from "../components/md-click";
import { Ripple } from "../components/ripple";
import { nearestCity } from "../lib/weather";
import { packById, savePack } from "../lib/packs";
import { goPage } from "../lib/nav";

export const Route = createFileRoute("/get-started")({ component: GetStarted });

function GetStarted() {
  const nav = useNavigate();
  const langPref = useStore((s) => s.langPref);
  const setLang = useStore((s) => s.setLang);
  const setSetupDone = useStore((s) => s.setSetupDone);
  const setNotifyOn = useStore((s) => s.setNotifyOn);
  const setBackgroundOn = useStore((s) => s.setBackgroundOn);
  const setLocationOn = useStore((s) => s.setLocationOn);
  const setInstalled = useStore((s) => s.setInstalled);
  const addWeatherCity = useStore((s) => s.addWeatherCity);
  const lang = useStore((s) => s.lang);
  const [step, setStep] = useState<"language" | "install" | "permissions">("language");
  const [notify, setNotify] = useState(false);
  const [bg, setBg] = useState(false);
  const [gps, setGps] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [shortcut, setShortcut] = useState(false);
  const [busy, setBusy] = useState(false);
  const kind = deviceKind();
  const packKind = packFor(kind);
  const ui = langPref === "auto" ? lang : langPref;

  function finish() {
    setLang(langPref);
    setSetupDone(true);
    goPage(nav, "/months");
  }

  function nextFromLang() {
    if (isPackaged()) setStep("permissions");
    else setStep("install");
  }

  async function askNotify() {
    try {
      const r = await Notification.requestPermission();
      const ok = r === "granted";
      setNotify(ok);
      if (ok) setNotifyOn(true);
    } catch {
      /* web */
    }
  }
  async function askBg() {
    const packaged = isPackaged();
    if (!packaged) {
      setMsg(t(ui, "webBgBlock"));
      return;
    }
    setBg(true);
    setBackgroundOn(true);
    setNotifyOn(true);
  }
  async function askGps() {
    try {
      const pos = await new Promise<GeolocationPosition>((res, rej) =>
        navigator.geolocation.getCurrentPosition(res, rej, { timeout: 8000 }),
      );
      setGps(true);
      setLocationOn(true);
      addWeatherCity(nearestCity(pos.coords.latitude, pos.coords.longitude).id);
    } catch {
      setGps(false);
    }
  }

  async function downloadDevicePack() {
    const pack = packKind ? packById(packKind) : null;
    if (!pack) {
      setShortcut(true);
      return;
    }
    setBusy(true);
    try {
      await savePack(pack.file, pack.name);
      setStep("permissions");
    } catch {
      setStep("permissions");
    } finally {
      setBusy(false);
    }
  }

  async function installBrowser() {
    const ev = (window as Window & { deferredPrompt?: { prompt: () => Promise<void> } }).deferredPrompt;
    if (ev) {
      await ev.prompt();
      setInstalled(true);
      setStep("permissions");
      return;
    }
    setShortcut(true);
  }

  const rows = [
    { id: "notify", label: t(ui, "setupAllowNotify"), ok: notify, onClick: askNotify },
    { id: "background", label: t(ui, "setupAllowBackground"), ok: bg, onClick: askBg },
    { id: "gps", label: t(ui, "setupAllowGps"), ok: gps, onClick: askGps },
  ];

  return (
    <div className="setup-screen">
      <div className="setup-card">
        <p className="setup-brand">{t(ui, "appName")}</p>
        {step === "language" ? (
          <>
            <h1 className="setup-title">{t(ui, "languageTitle")}</h1>
            <p className="setup-sub">{t(ui, "welcome")}</p>
            <LangRadios value={langPref} uiLang={ui} name="setup-lang" onPick={setLang} />
            <MdBtn tag="md-filled-button" className="setup-go" wide onClick={nextFromLang}>
              {t(ui, "setupNext")}
            </MdBtn>
          </>
        ) : null}
        {step === "install" ? (
          <>
            {packKind ? <OsLogo name={packKind} className="setup-os-logo" /> : null}
            <h1 className="setup-title">{packKind ? t(ui, "setupInstallTitle") : t(ui, "shortcutTitle")}</h1>
            <p className="setup-sub">
              {t(
                ui,
                kind === "android"
                  ? "setupInstallAndroid"
                  : kind === "windows"
                    ? "setupInstallWindows"
                    : kind === "macos"
                      ? "setupInstallMac"
                      : kind === "linux"
                        ? "setupInstallLinux"
                        : "setupInstallUnsupported",
              )}
            </p>
            {packKind ? (
              <MdBtn tag="md-filled-button" className="setup-go" wide disabled={busy} onClick={() => void downloadDevicePack()}>
                {busy ? t(ui, "exportDownloading") : t(ui, "setupInstallAction")}
              </MdBtn>
            ) : (
              <MdBtn tag="md-filled-button" className="setup-go" wide onClick={() => void installBrowser()}>
                {t(ui, "setupShortcutAction")}
              </MdBtn>
            )}
            <MdBtn tag="md-outlined-button" className="setup-skip" wide onClick={() => setStep("permissions")}>
              {t(ui, "setupSkipAnyway")}
            </MdBtn>
          </>
        ) : null}
        {step === "permissions" ? (
          <>
            <h1 className="setup-title">{t(ui, "setupPermTitle")}</h1>
            <p className="setup-sub">{t(ui, "setupPermSub")}</p>
            <div className="setup-perm-list">
              {rows.map((r) => (
                <button
                  key={r.id}
                  type="button"
                  className={`setup-perm-row has-ripple ${r.ok ? "is-on" : ""}`}
                  onClick={() => void r.onClick()}
                >
                  <Ripple />
                  <span className="setup-perm-label">{r.label}</span>
                  <Icon name={r.ok ? "check_box" : "close"} className={r.ok ? "setup-perm-ok" : "setup-perm-no"} />
                </button>
              ))}
            </div>
            <MdBtn
              tag="md-filled-button"
              className="setup-go"
              wide
              onClick={() => {
                if (notify) setNotifyOn(true);
                if (bg) setBackgroundOn(true);
                if (gps) setLocationOn(true);
                finish();
              }}
            >
              {t(ui, "setupContinue")}
            </MdBtn>
            <MdBtn tag="md-outlined-button" className="setup-skip" wide onClick={finish}>
              {t(ui, "setupSkip")}
            </MdBtn>
          </>
        ) : null}
      </div>
      <Dialog
        open={shortcut}
        title={t(ui, "shortcutTitle")}
        onClose={() => setShortcut(false)}
        actions={
          <>
            <DlgBtn secondary onClick={() => setShortcut(false)}>
              {t(ui, "cancel")}
            </DlgBtn>
            <DlgBtn
              onClick={() => {
                setInstalled(true);
                setShortcut(false);
                setStep("permissions");
              }}
            >
              {t(ui, "shortcutAdd")}
            </DlgBtn>
          </>
        }
      >
        <p>{t(ui, "shortcutAsk")}</p>
        <p className="calc-sub">{t(ui, "shortcutAndroid")}</p>
        <p className="calc-sub">{t(ui, "shortcutIos")}</p>
        <p className="calc-sub">{t(ui, "shortcutDesktop")}</p>
      </Dialog>
      <Dialog
        open={!!msg}
        title={t(ui, "info")}
        onClose={() => setMsg(null)}
        actions={<DlgBtn onClick={() => setMsg(null)}>{t(ui, "ok")}</DlgBtn>}
      >
        <p>{msg}</p>
      </Dialog>
    </div>
  );
}
