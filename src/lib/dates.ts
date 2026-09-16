import { khmerNum } from "./chhankitek";
import { monthsOf, t, weekdaysFull, type Lang } from "./i18n";

export function isoOf(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

export function fromIso(iso: string): Date {
  const [y, m, d] = iso.split("-").map(Number);
  return new Date(y, (m ?? 1) - 1, d ?? 1);
}

export function startOfMonth(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), 1);
}

export function addDays(d: Date, n: number): Date {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  x.setDate(x.getDate() + n);
  return x;
}

export function addMonths(d: Date, n: number): Date {
  const x = new Date(d.getFullYear(), d.getMonth() + n, 1);
  const day = Math.min(d.getDate(), daysInMonth(x));
  x.setDate(day);
  return x;
}

export function daysInMonth(d: Date): number {
  return new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate();
}

export function sameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

export function sameMonth(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth();
}

export function monthGrid(month: Date, weekStartsOn: 0 | 1 | 6): Date[] {
  const first = startOfMonth(month);
  const firstDow = first.getDay();
  const offset = (firstDow - weekStartsOn + 7) % 7;
  const start = addDays(first, -offset);
  return Array.from({ length: 42 }, (_, i) => addDays(start, i));
}

export function todayIso(): string {
  return isoOf(new Date());
}

export function roundTime5(): string {
  const e = new Date();
  const t = e.getMinutes();
  const n = Math.ceil(t / 5) * 5;
  const roll = n >= 60;
  const h = (e.getHours() + Number(roll)) % 24;
  const m = roll ? 0 : n;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`;
}

export function formatTime(hhmm: string): string {
  if (!hhmm) return "";
  const [h, m] = hhmm.split(":").map(Number);
  return `${String(h ?? 0).padStart(2, "0")}:${String(m ?? 0).padStart(2, "0")}`;
}

export function formatTime12(hhmm: string): string {
  if (!hhmm) return "";
  const [h, m] = hhmm.split(":").map(Number);
  if (!Number.isFinite(h) || !Number.isFinite(m)) return hhmm;
  const am = h < 12;
  return `${h % 12 || 12}:${String(m).padStart(2, "0")} ${am ? "AM" : "PM"}`;
}

export function formatMonthTitle(d: Date, lang: Lang) {
  const name = monthsOf(lang)[d.getMonth()];
  const y = d.getFullYear();
  return lang === "en" ? `${name} ${y}` : `${name} ${khmerNum(y)}`;
}

export function nowHm() {
  const e = new Date();
  return `${String(e.getHours()).padStart(2, "0")}:${String(e.getMinutes()).padStart(2, "0")}`;
}

export function reminderChipLabel(date: string, time: string, lang: Lang): string {
  if (!date) return t(lang, "addReminder");
  const today = todayIso();
  const d = fromIso(date);
  const months = monthsOf(lang);
  const wdays = weekdaysFull(lang);
  const dayMonth = `${d.getDate()} ${months[d.getMonth()]}`;
  const wday = wdays[d.getDay()];
  const tm = time ? formatTime12(time) : "";
  if (date === today) return tm ? `${t(lang, "today")}, ${tm}` : t(lang, "today");
  if (date.slice(0, 7) === today.slice(0, 7)) return tm ? `${dayMonth}, ${tm}` : dayMonth;
  const diff = Math.abs(d.getTime() - fromIso(today).getTime());
  if (diff < 7 * 86400000) return tm ? `${wday}, ${tm}` : wday;
  return tm ? `${dayMonth}, ${tm}` : dayMonth;
}

export function eventWhenLabel(date: string, startTime: string | undefined, allDay: boolean | undefined, lang: Lang): string {
  if (!date) return "";
  const d = fromIso(date);
  const today = fromIso(todayIso());
  const diff = Math.round((d.getTime() - today.getTime()) / 86400000);
  const months = monthsOf(lang);
  const wdays = weekdaysFull(lang);
  const label =
    diff === 0 ? t(lang, "today") : diff > 0 && diff < 7 ? wdays[d.getDay()] : `${d.getDate()} ${months[d.getMonth()]}`;
  if (allDay || !startTime) return label;
  return `${label}, ${formatTime12(startTime)}`;
}

export function eventWhenTone(date: string, done?: boolean): "" | "is-overdue" | "is-today" {
  if (done || !date) return "";
  const today = todayIso();
  if (date < today) return "is-overdue";
  if (date === today) return "is-today";
  return "";
}

export function showNativePicker(el: HTMLInputElement | null) {
  if (!el) return;
  try {
    if (typeof el.showPicker === "function") {
      el.showPicker();
      return;
    }
  } catch {
    /* fall through */
  }
  el.focus();
  el.click();
}

export function joinTitleNotes(title: string, notes?: string) {
  return title && notes ? `${title}\n${notes}` : notes || title;
}

export function splitTitleNotes(raw: string) {
  const text = raw.replace(/\r\n/g, "\n").trim();
  const n = text.indexOf("\n");
  if (n === -1) return { title: text, notes: "" };
  return { title: text.slice(0, n).trim(), notes: text.slice(n + 1) };
}
