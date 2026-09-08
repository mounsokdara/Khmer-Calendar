import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import { useEffect } from "react";
import { deviceLang, resolveLang, type Lang, type LangPref } from "./i18n";
import { applyTheme, type ColorSchemeId } from "./theme";
import { isoOf, todayIso } from "./dates";

export type CalendarEvent = {
  id: string;
  title: string;
  notes?: string;
  date: string;
  endDate?: string;
  startTime?: string;
  endTime?: string;
  allDay?: boolean;
  reminderDate?: string;
  reminderTime?: string;
  done?: boolean;
};

export type TabId = "today" | "months" | "events" | "weather" | "more";

const DEFAULT_CITIES = ["phnom-penh", "banteay-meanchey", "kampong-cham", "kratie"] as const;
const SEED_TITLES = new Set(["ប្រជុំក្រុមការងារ", "ធ្វើបុណ្យទាន", "ពិធីគ្រួសារ", "ផ្សារទំនើប"]);
const SEED_IDS = new Set(["seed-meeting", "seed-offering", "seed-family"]);

export function isSeed(e: CalendarEvent) {
  return SEED_IDS.has(e.id) || SEED_TITLES.has(e.title);
}

type ThemeMode = "light" | "dark" | "system";

type State = {
  events: CalendarEvent[];
  cursor: string;
  selected: string;
  theme: ThemeMode;
  colorScheme: ColorSchemeId;
  materialYou: boolean;
  extraDark: boolean;
  accentColor: string;
  highlightColor: string;
  highlightAlpha: number;
  lang: Lang;
  langPref: LangPref;
  setupDone: boolean;
  lastTab: TabId;
  lastEventsPane: "holidays" | "tasks";
  weatherCities: string[];
  installed: boolean;
  notifyOn: boolean;
  backgroundOn: boolean;
  locationOn: boolean;
  autoLaunchOn: boolean;
  weekStartsOn: 0 | 1 | 6;
  hydrated: boolean;
  addEvent: (e: CalendarEvent) => void;
  updateEvent: (e: CalendarEvent) => void;
  deleteEvent: (id: string) => void;
  toggleEventDone: (id: string) => void;
  setCursor: (iso: string) => void;
  setSelected: (iso: string) => void;
  goToDate: (iso: string) => void;
  setTheme: (t: ThemeMode) => void;
  setColorScheme: (id: ColorSchemeId) => void;
  setMaterialYou: (v: boolean) => void;
  setExtraDark: (v: boolean) => void;
  setAccentColor: (v: string) => void;
  setHighlightColor: (v: string) => void;
  setHighlightAlpha: (v: number) => void;
  setLang: (v: LangPref) => void;
  setSetupDone: (v: boolean) => void;
  setLastTab: (v: TabId) => void;
  setLastEventsPane: (v: "holidays" | "tasks") => void;
  addWeatherCity: (id: string) => void;
  removeWeatherCity: (id: string) => void;
  setInstalled: (v: boolean) => void;
  setNotifyOn: (v: boolean) => void;
  setBackgroundOn: (v: boolean) => void;
  setLocationOn: (v: boolean) => void;
  setAutoLaunchOn: (v: boolean) => void;
  setWeekStartsOn: (v: 0 | 1 | 6) => void;
  clearEventReminders: () => void;
  resetWeatherCities: () => void;
  resetAppData: () => void;
  paintTheme: () => void;
};

function paint(s: State) {
  applyTheme({
    theme: s.theme,
    colorScheme: s.colorScheme,
    materialYou: s.materialYou,
    extraDark: s.extraDark,
    accentColor: s.accentColor,
    highlightColor: s.highlightColor,
    highlightAlpha: s.highlightAlpha,
  });
  if (typeof document !== "undefined") {
    document.documentElement.lang = s.lang;
    document.title = s.lang === "en" ? "Khmer Calendar" : "ប្រតិទិនខ្មែរ";
  }
}

const memory = () => {
  const m = new Map<string, string>();
  return {
    getItem: (k: string) => m.get(k) ?? null,
    setItem: (k: string, v: string) => {
      m.set(k, v);
    },
    removeItem: (k: string) => {
      m.delete(k);
    },
  };
};

function storage() {
  if (typeof window === "undefined") return memory();
  try {
    const t = "__khmer_cal_probe";
    localStorage.setItem(t, "1");
    localStorage.removeItem(t);
    return localStorage;
  } catch {
    return memory();
  }
}

export const useStore = create<State>()(
  persist(
    (set, get) => ({
      events: [],
      cursor: todayIso(),
      selected: todayIso(),
      theme: "system",
      colorScheme: "rose",
      materialYou: true,
      extraDark: false,
      accentColor: "#F5C400",
      highlightColor: "#FF3B30",
      highlightAlpha: 0.22,
      lang: deviceLang(),
      langPref: "auto",
      setupDone: false,
      lastTab: "months",
      lastEventsPane: "holidays",
      weatherCities: [...DEFAULT_CITIES],
      installed: false,
      notifyOn: false,
      backgroundOn: false,
      locationOn: false,
      autoLaunchOn: false,
      weekStartsOn: 1,
      hydrated: false,
      addEvent: (e) => set((s) => ({ events: [...s.events, e] })),
      updateEvent: (e) => set((s) => ({ events: s.events.map((x) => (x.id === e.id ? e : x)) })),
      deleteEvent: (id) => set((s) => ({ events: s.events.filter((x) => x.id !== id) })),
      toggleEventDone: (id) =>
        set((s) => ({ events: s.events.map((x) => (x.id === id ? { ...x, done: !x.done } : x)) })),
      setCursor: (iso) => set({ cursor: iso }),
      setSelected: (iso) => set({ selected: iso }),
      goToDate: (iso) => set({ cursor: iso, selected: iso }),
      setTheme: (theme) => {
        set({ theme });
        paint(get());
      },
      setColorScheme: (colorScheme) => {
        set({ colorScheme, materialYou: true });
        paint(get());
      },
      setMaterialYou: (materialYou) => {
        set({ materialYou });
        paint(get());
      },
      setExtraDark: (extraDark) => {
        set({ extraDark });
        paint(get());
      },
      setAccentColor: (accentColor) => {
        set({ accentColor });
        paint(get());
      },
      setHighlightColor: (highlightColor) => {
        set({ highlightColor });
        paint(get());
      },
      setHighlightAlpha: (highlightAlpha) => {
        set({ highlightAlpha: Math.min(1, Math.max(0, highlightAlpha)) });
        paint(get());
      },
      setLang: (pref) => {
        const lang = resolveLang(pref);
        set({ langPref: pref, lang });
        paint(get());
      },
      setSetupDone: (setupDone) => set({ setupDone }),
      setLastTab: (lastTab) => set({ lastTab }),
      setLastEventsPane: (lastEventsPane) => set({ lastEventsPane }),
      addWeatherCity: (id) =>
        set((s) => (s.weatherCities.includes(id) ? s : { weatherCities: [...s.weatherCities, id] })),
      removeWeatherCity: (id) =>
        set((s) => ({ weatherCities: s.weatherCities.filter((c) => c !== id) })),
      setInstalled: (installed) => set({ installed }),
      setNotifyOn: (notifyOn) => set({ notifyOn }),
      setBackgroundOn: (backgroundOn) => set({ backgroundOn }),
      setLocationOn: (locationOn) => set({ locationOn }),
      setAutoLaunchOn: (autoLaunchOn) => set({ autoLaunchOn }),
      setWeekStartsOn: (weekStartsOn) => set({ weekStartsOn }),
      clearEventReminders: () =>
        set((s) => ({
          events: s.events.map((e) => ({ ...e, reminderDate: "", reminderTime: "" })),
        })),
      resetWeatherCities: () => set({ weatherCities: [...DEFAULT_CITIES] }),
      resetAppData: () => {
        set({
          events: [],
          theme: "system",
          colorScheme: "rose",
          materialYou: true,
          extraDark: false,
          accentColor: "#F5C400",
          highlightColor: "#FF3B30",
          highlightAlpha: 0.22,
          lastEventsPane: "holidays",
          weatherCities: [...DEFAULT_CITIES],
          installed: false,
          notifyOn: false,
          backgroundOn: false,
          locationOn: false,
          autoLaunchOn: false,
          weekStartsOn: 1,
        });
        paint(get());
      },
      paintTheme: () => paint(get()),
    }),
    {
      name: "khmer-calendar-v3",
      version: 18,
      storage: createJSONStorage(() => storage()),
      skipHydration: true,
      partialize: (s) => ({
        events: s.events.filter((e) => !isSeed(e)),
        theme: s.theme,
        colorScheme: s.colorScheme,
        materialYou: s.materialYou,
        extraDark: s.extraDark,
        accentColor: s.accentColor,
        highlightColor: s.highlightColor,
        highlightAlpha: s.highlightAlpha,
        lang: s.lang,
        langPref: s.langPref,
        setupDone: s.setupDone,
        lastTab: s.lastTab,
        lastEventsPane: s.lastEventsPane,
        weatherCities: s.weatherCities,
        installed: s.installed,
        notifyOn: s.notifyOn,
        backgroundOn: s.backgroundOn,
        locationOn: s.locationOn,
        autoLaunchOn: s.autoLaunchOn,
        weekStartsOn: s.weekStartsOn,
      }),
      merge: (persisted, current) => {
        const p = (persisted ?? {}) as Partial<State>;
        const events = (p.events ?? []).filter((e) => !isSeed(e));
        const langPref = p.langPref ?? current.langPref;
        return {
          ...current,
          ...p,
          events,
          langPref,
          lang: resolveLang(langPref),
        };
      },
      onRehydrateStorage: () => (state) => {
        if (!state) {
          useStore.setState({ hydrated: true });
          return;
        }
        state.events = (state.events ?? []).filter((e) => !isSeed(e));
        state.lang = resolveLang(state.langPref ?? "auto");
        state.hydrated = true;
        state.paintTheme();
      },
    },
  ),
);

export function useHydrateStore() {
  useEffect(() => {
    const api = useStore.persist;
    const finish = () => {
      if (!useStore.getState().hydrated) useStore.setState({ hydrated: true });
      useStore.getState().paintTheme();
    };
    if (api.hasHydrated()) {
      finish();
      return;
    }
    const unsub = api.onFinishHydration(finish);
    void api.rehydrate();
    const t = window.setTimeout(finish, 400);
    return () => {
      unsub();
      window.clearTimeout(t);
    };
  }, []);
}

export function newId() {
  return `evt-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 7)}`;
}

export function eventsOn(events: CalendarEvent[], iso: string) {
  return events.filter((e) => e.date === iso);
}

export { todayIso, isoOf };
