import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useStore } from "../../lib/store";
import { t } from "../../lib/i18n";
import { SubHead, ToggleRow, SetGroup, isPackaged } from "../../components/settings-ui";
import { Dialog, DlgBtn } from "../../components/dialog";
import { nearestCity } from "../../lib/weather";

export const Route = createFileRoute("/settings/privacyandpermission")({ component: PrivacyPage });

function PrivacyPage() {
  const lang = useStore((s) => s.lang);
  const notifyOn = useStore((s) => s.notifyOn);
  const backgroundOn = useStore((s) => s.backgroundOn);
  const locationOn = useStore((s) => s.locationOn);
  const autoLaunchOn = useStore((s) => s.autoLaunchOn);
  const setNotifyOn = useStore((s) => s.setNotifyOn);
  const setBackgroundOn = useStore((s) => s.setBackgroundOn);
  const setLocationOn = useStore((s) => s.setLocationOn);
  const setAutoLaunchOn = useStore((s) => s.setAutoLaunchOn);
  const addWeatherCity = useStore((s) => s.addWeatherCity);
  const [msg, setMsg] = useState<string | null>(null);

  async function toggleNotify() {
    if (notifyOn) {
      setNotifyOn(false);
      return;
    }
    try {
      const r = await Notification.requestPermission();
      if (r !== "granted") {
        setMsg(t(lang, "permDenied"));
        return;
      }
      setNotifyOn(true);
    } catch {
      setMsg(t(lang, "permDenied"));
    }
  }

  function toggleBg() {
    if (backgroundOn) {
      setBackgroundOn(false);
      return;
    }
    if (!isPackaged()) {
      setMsg(t(lang, "webBgBlock"));
      return;
    }
    setBackgroundOn(true);
  }

  async function toggleGps() {
    if (locationOn) {
      setLocationOn(false);
      return;
    }
    try {
      const pos = await new Promise<GeolocationPosition>((res, rej) =>
        navigator.geolocation.getCurrentPosition(res, rej, { timeout: 8000 }),
      );
      setLocationOn(true);
      addWeatherCity(nearestCity(pos.coords.latitude, pos.coords.longitude).id);
    } catch {
      setMsg(t(lang, "noLocation"));
    }
  }

  function toggleAuto() {
    if (autoLaunchOn) {
      setAutoLaunchOn(false);
      return;
    }
    if (!isPackaged()) {
      setMsg(t(lang, "webBgBlock"));
      return;
    }
    setAutoLaunchOn(true);
  }

  return (
    <div className="more-layout set-page">
      <SubHead title={t(lang, "privacyTitle")} backTo="/settings" />
      <SetGroup>
        <ToggleRow icon="notifications" title={t(lang, "permNotify")} subtitle={t(lang, "permNotifySub")} checked={notifyOn} onToggle={() => void toggleNotify()} />
        <ToggleRow icon="sync" title={t(lang, "permBackground")} subtitle={t(lang, "permBackgroundSub")} checked={backgroundOn} onToggle={toggleBg} />
        <ToggleRow icon="rocket_launch" title={t(lang, "autoLaunch")} subtitle={t(lang, "autoLaunchSub")} checked={autoLaunchOn} onToggle={toggleAuto} />
        <ToggleRow icon="location_on" title={t(lang, "permLocation")} subtitle={t(lang, "permLocationSub")} checked={locationOn} onToggle={() => void toggleGps()} />
      </SetGroup>
      <Dialog
        open={!!msg}
        title={t(lang, "info")}
        onClose={() => setMsg(null)}
        actions={<DlgBtn onClick={() => setMsg(null)}>{t(lang, "ok")}</DlgBtn>}
      >
        <p>{msg}</p>
      </Dialog>
    </div>
  );
}
