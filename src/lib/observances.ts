import {
  dayInfo,
  holidaysOfYear,
  holidaysOn,
  khmerNum,
  lunarOf,
  MONTH_EN,
  type Holiday,
  type LunarDay,
} from "./chhankitek";
import { addDays, fromIso, isoOf } from "./dates";
import { t, type Lang } from "./i18n";
import type { CalendarEvent } from "./store";

export type Kind = "holiday" | "sil" | "event";

export type Observance = {
  id: string;
  date: string;
  title: string;
  titleEn: string;
  subtitle?: string;
  subtitleEn?: string;
  kind: Kind;
  holidayType?: Holiday["type"];
  eventId?: string;
};

const TYPE_KM: Record<Holiday["type"], string> = {
  public: "ថ្ងៃឈប់សម្រាកសាធារណៈ",
  religious: "ថ្ងៃបុណ្យសាសនា",
  traditional: "ថ្ងៃប្រពៃណីខ្មែរ",
};

const kanCache = new Map<number, Observance[]>();
const ktCache = new Map<number, Observance[]>();

function eachDay(start: Date, end: Date): Date[] {
  const out: Date[] = [];
  const d = new Date(start.getFullYear(), start.getMonth(), start.getDate());
  const last = new Date(end.getFullYear(), end.getMonth(), end.getDate());
  while (d <= last) {
    out.push(new Date(d));
    d.setDate(d.getDate() + 1);
  }
  return out;
}

function pchumBenDate(year: number): Date | null {
  const list = holidaysOfYear(year);
  const h =
    list.find((x) => x.nameKm === "ភ្ជុំបិណ្ឌ" && x.type === "religious") ??
    list.find((x) => x.nameEn === "Pchum Ben" && x.type === "religious");
  return h ? fromIso(h.date) : null;
}

export function kanBenOf(year: number): Observance[] {
  const hit = kanCache.get(year);
  if (hit) return hit;
  const pb = pchumBenDate(year);
  if (!pb) {
    kanCache.set(year, []);
    return [];
  }
  const list: Observance[] = [];
  for (let i = 1; i <= 14; i += 1) {
    const iso = isoOf(addDays(pb, -(15 - i)));
    list.push({
      id: `kanben-${iso}`,
      date: iso,
      title: `បិណ្ឌ ${khmerNum(i)}`,
      titleEn: `Kan Ben ${i}`,
      subtitle: "ពិធីបុណ្យភ្ជុំបិណ្ឌ",
      subtitleEn: "Pchum Ben",
      kind: "holiday",
      holidayType: "traditional",
    });
  }
  kanCache.set(year, list);
  return list;
}

export function senKantongOf(year: number): Observance[] {
  const hit = ktCache.get(year);
  if (hit) return hit;
  const list: Observance[] = [];
  for (const d of eachDay(new Date(year, 7, 1), new Date(year, 10, 30))) {
    const iso = isoOf(d);
    const L = lunarOf(d);
    if (L.khmerMonth === "ភទ្របទ" && L.moonDay === 14 && L.moonStatus === "កើត") {
      list.push({
        id: `kantong-${iso}`,
        date: iso,
        title: "សែនកន្ទោងទឹក",
        titleEn: "Sen Kantong",
        subtitle: "ពិធីបុណ្យភ្ជុំបិណ្ឌ",
        subtitleEn: "Pchum Ben",
        kind: "holiday",
        holidayType: "traditional",
      });
    }
  }
  ktCache.set(year, list);
  return list;
}

function eventObservances(events: CalendarEvent[]): Observance[] {
  const out: Observance[] = [];
  for (const n of events) {
    if (!n.date) {
      out.push({
        id: `evt-${n.id}`,
        date: "",
        title: n.title,
        titleEn: n.title,
        subtitle: n.startTime && !n.allDay ? n.startTime : "",
        subtitleEn: n.startTime && !n.allDay ? n.startTime : "",
        kind: "event",
        eventId: n.id,
      });
      continue;
    }
    const start = fromIso(n.date);
    const end = fromIso(n.endDate || n.date);
    const days = eachDay(start, end < start ? start : end);
    const sub = n.allDay ? t("km", "allDay") : n.startTime ? `${n.startTime}${n.endTime ? `–${n.endTime}` : ""}` : "";
    const subEn = n.allDay ? t("en", "allDay") : n.startTime ? `${n.startTime}${n.endTime ? `–${n.endTime}` : ""}` : "";
    for (const d of days) {
      const iso = isoOf(d);
      out.push({
        id: `evt-${n.id}-${iso}`,
        date: iso,
        title: n.title,
        titleEn: n.title,
        subtitle: sub,
        subtitleEn: subEn,
        kind: "event",
        eventId: n.id,
      });
    }
  }
  return out;
}

function kindRank(k: Kind) {
  return k === "holiday" ? 0 : k === "sil" ? 1 : 2;
}

export function rangeObservances(start: Date, end: Date, events: CalendarEvent[]): Observance[] {
  const days = eachDay(start, end);
  const years = new Set(days.map((d) => d.getFullYear()));
  const extra = new Map<string, Observance[]>();
  for (const y of years) {
    for (const o of [...kanBenOf(y), ...senKantongOf(y)]) {
      const arr = extra.get(o.date) ?? [];
      arr.push(o);
      extra.set(o.date, arr);
    }
  }
  const out: Observance[] = [];
  const seen = new Set<string>();
  for (const d of days) {
    const iso = isoOf(d);
    const info = dayInfo(iso);
    const hols = info.holidays?.length ? info.holidays : holidaysOn(iso);
    for (const h of hols) {
      const id = `hol-${iso}-${h.nameKm}`;
      if (seen.has(id)) continue;
      seen.add(id);
      out.push({
        id,
        date: iso,
        title: h.nameKm,
        titleEn: h.nameEn || h.nameKm,
        subtitle: TYPE_KM[h.type],
        subtitleEn: holidayTypeLabel(h.type, "en"),
        kind: "holiday",
        holidayType: h.type,
      });
    }
    for (const o of extra.get(iso) ?? []) out.push(o);
    if (info.isSilDay) {
      const wax = info.moonStatus === "កើត" ? "waxing" : "waning";
      out.push({
        id: `sil-${iso}`,
        date: iso,
        title: "ថ្ងៃសីល",
        titleEn: "Silas day",
        subtitle: `${info.moonDayKhmer}${info.moonStatus} ខែ${info.khmerMonth}`,
        subtitleEn: `${info.moonDay} ${wax} ${MONTH_EN[info.khmerMonth] ?? info.khmerMonth}`,
        kind: "sil",
      });
    }
  }
  const startIso = isoOf(start);
  const endIso = isoOf(end);
  return [...out, ...eventObservances(events).filter((e) => e.date && e.date >= startIso && e.date <= endIso)].sort(
    (a, b) => a.date.localeCompare(b.date) || kindRank(a.kind) - kindRank(b.kind) || a.title.localeCompare(b.title, "km"),
  );
}

export function yearObservances(year: number, events: CalendarEvent[] = []): Observance[] {
  return rangeObservances(new Date(year, 0, 1), new Date(year, 11, 31), events);
}

export function monthObservances(month: Date, events: CalendarEvent[], _lang?: Lang): Observance[] {
  const start = new Date(month.getFullYear(), month.getMonth(), 1);
  const end = new Date(month.getFullYear(), month.getMonth() + 1, 0);
  return rangeObservances(start, end, events);
}

export function observancesOn(iso: string, events: CalendarEvent[], _lang?: Lang): Observance[] {
  const d = fromIso(iso);
  return rangeObservances(d, d, events);
}

export function obsTitle(o: Observance, lang: Lang) {
  return lang === "en" && o.titleEn ? o.titleEn : o.title;
}

export function obsSub(o: Observance, lang: Lang) {
  return lang === "en" && o.subtitleEn ? o.subtitleEn : o.subtitle;
}

export function holidayTitle(h: Holiday, lang: Lang) {
  return lang === "en" ? h.nameEn : h.nameKm;
}

export function holidayTypeLabel(type: Holiday["type"], lang: Lang) {
  if (type === "public") return t(lang, "holidayPublic");
  if (type === "religious") return t(lang, "holidayReligious");
  return t(lang, "holidayTraditional");
}

export function colorKind(o: Observance) {
  if (o.kind === "sil") return "sil";
  if (o.kind === "event") return "event";
  return o.holidayType === "public" ? "sunday" : "holiday";
}

export function isPublicHoliday(iso: string) {
  return holidaysOn(iso).some((h) => h.type === "public");
}

export function dayTone(iso: string, inMonth: boolean, _lunar?: LunarDay, _hols?: Holiday[]): "default" | "muted" | "sunday" | "holiday" {
  if (!inMonth) return "muted";
  const d = fromIso(iso);
  if (d.getDay() === 0 || isPublicHoliday(iso)) return "sunday";
  const info = dayInfo(iso);
  if ((info.holidays && info.holidays.length) || holidaysOn(iso).length) return "holiday";
  const y = d.getFullYear();
  if (kanBenOf(y).some((o) => o.date === iso) || senKantongOf(y).some((o) => o.date === iso)) return "holiday";
  return "default";
}

export function hasDayMark(iso: string, events: CalendarEvent[]): boolean {
  return events.some((e) => e.date === iso);
}

export function gregorianLabel(d: Date, lang: Lang) {
  const months = lang === "en"
    ? ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    : ["មករា", "កុម្ភៈ", "មីនា", "មេសា", "ឧសភា", "មិថុនា", "កក្កដា", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិកា", "ធ្នូ"];
  return lang === "en"
    ? `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`
    : `ថ្ងៃទី${d.getDate()} ខែ${months[d.getMonth()]} ឆ្នាំ${d.getFullYear()}`;
}

export function lunarLabel(iso: string, lang: Lang) {
  const n = lunarOf(fromIso(iso));
  const wax = n.moonStatus === "កើត" ? "waxing" : "waning";
  const wdayEn: Record<string, string> = {
    អាទិត្យ: "Sunday",
    ចន្ទ: "Monday",
    អង្គារ: "Tuesday",
    ពុធ: "Wednesday",
    ព្រហស្បតិ៍: "Thursday",
    សុក្រ: "Friday",
    សៅរ៍: "Saturday",
  };
  return lang === "en"
    ? `${wdayEn[n.dayOfWeek] ?? n.dayOfWeek} ${n.moonDay} ${wax} ${MONTH_EN[n.khmerMonth] ?? n.khmerMonth} · B.E. ${n.buddhistEraYear}`
    : `ថ្ងៃ${n.dayOfWeek} ${n.moonDayKhmer}${n.moonStatus} ខែ${n.khmerMonth} ព.ស. ${n.buddhistEraYearKhmer}`;
}
