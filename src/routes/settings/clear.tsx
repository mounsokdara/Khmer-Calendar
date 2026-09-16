import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useStore } from "../../lib/store";
import { t } from "../../lib/i18n";
import { ActionRow, SetGroup, SubHead } from "../../components/settings-ui";
import { ConfirmDelete } from "../../components/dialog";
import { StackBar } from "../../components/stack-bar";

export const Route = createFileRoute("/settings/clear")({ component: ClearPage });

function ClearPage() {
  const lang = useStore((s) => s.lang);
  const clearEventReminders = useStore((s) => s.clearEventReminders);
  const resetWeatherCities = useStore((s) => s.resetWeatherCities);
  const resetAppData = useStore((s) => s.resetAppData);
  const [ask, setAsk] = useState<"cache" | "reminders" | "weather" | "all" | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  async function run() {
    if (ask === "cache" && "caches" in window) {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
    }
    if (ask === "reminders") clearEventReminders();
    if (ask === "weather") resetWeatherCities();
    if (ask === "all") {
      if ("caches" in window) {
        const keys = await caches.keys();
        await Promise.all(keys.map((k) => caches.delete(k)));
      }
      resetAppData();
    }
    setAsk(null);
    setToast(t(lang, "clearDone"));
  }

  return (
    <div className="more-layout set-page">
      <SubHead title={t(lang, "clearTitle")} backTo="/settings" />
      <SetGroup>
        <ActionRow icon="cached" title={t(lang, "clearCache")} subtitle={t(lang, "clearCacheSub")} onClick={() => setAsk("cache")} />
        <ActionRow icon="notifications_off" title={t(lang, "clearReminders")} subtitle={t(lang, "clearRemindersSub")} onClick={() => setAsk("reminders")} />
        <ActionRow icon="cloud_off" title={t(lang, "clearWeather")} subtitle={t(lang, "clearWeatherSub")} onClick={() => setAsk("weather")} />
        <ActionRow icon="delete_forever" title={t(lang, "clearAll")} subtitle={t(lang, "clearAllSub")} danger onClick={() => setAsk("all")} />
      </SetGroup>
      <ConfirmDelete
        open={!!ask}
        lang={lang}
        title={
          ask === "cache"
            ? t(lang, "confirmClearCache")
            : ask === "reminders"
              ? t(lang, "confirmClearReminders")
              : ask === "weather"
                ? t(lang, "confirmClearWeather")
                : t(lang, "confirmClearAll")
        }
        onCancel={() => setAsk(null)}
        onDelete={() => void run()}
      />
      <StackBar open={!!toast} message={toast ?? ""} onDismiss={() => setToast(null)} />
    </div>
  );
}
