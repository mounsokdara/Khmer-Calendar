import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState } from "react";
import { Icon } from "../components/icon";
import { SilMark } from "../components/sil-mark";
import { Dialog, DlgBtn } from "../components/dialog";
import { TaskSheet } from "../components/task-sheet";
import { useStore } from "../lib/store";
import { t, monthsOf, weekdaysStarting, sundayIndex, type Lang } from "../lib/i18n";
import { addMonths, formatMonthTitle, fromIso, isoOf, monthGrid, sameDay, sameMonth, todayIso } from "../lib/dates";
import { lunarOf } from "../lib/chhankitek";
import { colorKind, dayTone, hasDayMark, monthObservances, obsTitle, type Observance } from "../lib/observances";
import { HolidayInfo } from "../components/holiday-info";
import { goPage } from "../lib/nav";
import { MdIconBtn } from "../components/md-click";
import { Ripple } from "../components/ripple";

export const Route = createFileRoute("/months")({ component: MonthsPage });

function WheelCol({
  labels,
  index,
  onIndex,
  kind,
  ariaLabel,
}: {
  labels: string[];
  index: number;
  onIndex: (i: number) => void;
  kind: "month" | "year";
  ariaLabel: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [typing, setTyping] = useState(false);
  const [val, setVal] = useState("");
  useEffect(() => {
    const el = ref.current;
    if (el && !typing) el.scrollTop = index * 52;
  }, [index, typing]);
  return (
    <div className={`wheel-col ${typing ? "is-typing" : ""}`}>
      {typing ? (
        <input
          className="wheel-type"
          data-selectable=""
          value={val}
          autoFocus
          aria-label={ariaLabel}
          onChange={(e) => setVal(e.target.value)}
          onBlur={() => {
            const n =
              kind === "year"
                ? labels.indexOf(val.replace(/\D/g, ""))
                : labels.findIndex((l) => l.toLowerCase().startsWith(val.toLowerCase()));
            if (n >= 0) onIndex(n);
            setTyping(false);
          }}
          onKeyDown={(e) => {
            if (e.key === "Enter") (e.target as HTMLInputElement).blur();
            if (e.key === "Escape") setTyping(false);
          }}
        />
      ) : (
        <button
          type="button"
          className="wheel-mark"
          aria-label={ariaLabel}
          onClick={() => {
            setVal(labels[index] ?? "");
            setTyping(true);
          }}
        >
          <svg className="wheel-mark-svg" viewBox="0 0 100 52" preserveAspectRatio="none" aria-hidden="true">
            <rect className="wheel-mark-hit" x="2" y="2" width="96" height="48" rx="24" />
            <rect className="wheel-mark-stroke" x="2" y="2" width="96" height="48" rx="24" />
          </svg>
        </button>
      )}
      <div
        ref={ref}
        className="wheel-scroller"
        role="listbox"
        aria-label={ariaLabel}
        onScroll={(e) => {
          if (typing) return;
          const i = Math.round(e.currentTarget.scrollTop / 52);
          if (i !== index && i >= 0 && i < labels.length) onIndex(i);
        }}
      >
        <div className="wheel-pad" />
        {labels.map((l, i) => (
          <button
            key={`${l}-${i}`}
            type="button"
            role="option"
            aria-selected={i === index}
            className={`wheel-item ${i === index ? "is-on" : ""}`}
            onClick={() => onIndex(i)}
          >
            {l}
          </button>
        ))}
        <div className="wheel-pad" />
      </div>
    </div>
  );
}

function ObsList({
  items,
  emptyText,
  selectedDate,
  onOpen,
  lang,
}: {
  items: Observance[];
  emptyText: string;
  selectedDate: string;
  onOpen: (item: Observance) => void;
  lang: Lang;
}) {
  if (items.length === 0) return <p className="px-5 py-8 text-sm text-on-variant">{emptyText}</p>;
  return (
    <div className="flex flex-col py-1">
      {items.map((item) => (
        <button
          key={item.id}
          type="button"
          className={`obs-row ${selectedDate === item.date ? "is-active" : ""}`}
          onClick={() => onOpen(item)}
        >
          <Ripple />
          <span className={`obs-date ${colorKind(item)}`}>{fromIso(item.date).getDate()}</span>
          <span className="obs-copy">
            <span className="obs-title">{obsTitle(item, lang)}</span>
          </span>
        </button>
      ))}
    </div>
  );
}

function MonthsPage() {
  const nav = useNavigate();
  const lang = useStore((s) => s.lang);
  const cursorIso = useStore((s) => s.cursor);
  const selectedIso = useStore((s) => s.selected);
  const events = useStore((s) => s.events);
  const weekStartsOn = useStore((s) => s.weekStartsOn);
  const setCursor = useStore((s) => s.setCursor);
  const goToDate = useStore((s) => s.goToDate);
  const addEvent = useStore((s) => s.addEvent);
  const updateEvent = useStore((s) => s.updateEvent);
  const deleteEvent = useStore((s) => s.deleteEvent);
  const cursor = fromIso(cursorIso);
  const selected = fromIso(selectedIso);
  const today = fromIso(todayIso());
  const [expanded, setExpanded] = useState(false);
  const [wheel, setWheel] = useState(false);
  const [sheet, setSheet] = useState(false);
  const [info, setInfo] = useState<Observance | null>(null);
  const [editId, setEditId] = useState<string | null>(null);
  const months = monthsOf(lang);
  const labels = weekdaysStarting(lang, weekStartsOn);
  const sunAt = sundayIndex(weekStartsOn);
  const items = useMemo(() => monthObservances(cursor, events, lang).filter((i) => i.kind !== "sil"), [cursorIso, events, lang]);
  const holidays = items.filter((i) => i.kind !== "event");
  const tasks = items.filter((i) => i.kind === "event");
  const L = lunarOf(cursor);

  const track = useRef<HTMLDivElement>(null);
  const wrap = useRef<HTMLDivElement>(null);
  const dragging = useRef(false);
  const axis = useRef<"x" | "y" | null>(null);
  const startX = useRef(0);
  const startY = useRef(0);
  const dx = useRef(0);
  const pending = useRef(0);

  function swipeTo(dir: number) {
    pending.current = dir;
    const w = wrap.current?.offsetWidth || 1;
    if (track.current) {
      track.current.style.transition = "transform 320ms cubic-bezier(0.2, 0, 0, 1)";
      track.current.style.transform = `translate3d(calc(-33.333% + ${dir < 0 ? w : -w}px),0,0)`;
    }
  }

  useEffect(() => {
    if (track.current) {
      track.current.style.transition = "none";
      track.current.style.transform = "translate3d(-33.333%,0,0)";
    }
  }, [cursorIso]);

  useEffect(() => {
    const el = wrap.current;
    if (!el) return;
    const move = (ev: PointerEvent) => {
      const n = ev.clientX - startX.current;
      const r = ev.clientY - startY.current;
      if (!axis.current) {
        if (Math.abs(n) < 10 && Math.abs(r) < 10) return;
        axis.current = Math.abs(n) > Math.abs(r) ? "x" : "y";
        if (axis.current === "x") {
          dragging.current = true;
          el.classList.add("is-dragging");
        }
      }
      if (axis.current !== "x") return;
      ev.preventDefault();
      dx.current = n;
      const w = el.offsetWidth || 1;
      if (track.current) {
        track.current.style.transition = "none";
        track.current.style.transform = `translate3d(calc(-33.333% + ${Math.max(-w, Math.min(w, n))}px),0,0)`;
      }
    };
    const up = () => {
      document.removeEventListener("pointermove", move);
      document.removeEventListener("pointerup", up);
      el.classList.remove("is-dragging");
      if (!dragging.current) return;
      const w = el.offsetWidth || 1;
      if (dx.current > Math.max(48, w * 0.18)) swipeTo(-1);
      else if (dx.current < -Math.max(48, w * 0.18)) swipeTo(1);
      else if (track.current) {
        track.current.style.transition = "transform 320ms cubic-bezier(0.2, 0, 0, 1)";
        track.current.style.transform = "translate3d(-33.333%,0,0)";
      }
    };
    const down = (e: PointerEvent) => {
      if (e.button !== 0) return;
      if (pending.current) {
        setCursor(isoOf(addMonths(fromIso(useStore.getState().cursor), pending.current)));
        pending.current = 0;
      }
      startX.current = e.clientX;
      startY.current = e.clientY;
      dx.current = 0;
      dragging.current = false;
      axis.current = null;
      document.addEventListener("pointermove", move, { passive: false });
      document.addEventListener("pointerup", up);
    };
    el.addEventListener("pointerdown", down);
    return () => el.removeEventListener("pointerdown", down);
  }, [setCursor]);

  function Grid({ month, interactive }: { month: Date; interactive: boolean }) {
    const days = monthGrid(month, weekStartsOn);
    const chips = interactive
      ? monthObservances(month, events, lang).filter((i) => i.kind !== "sil")
      : [];
    return (
      <div className="month-grid">
        {days.map((d) => {
          const iso = isoOf(d);
          const inM = sameMonth(d, month);
          const lunar = lunarOf(d);
          const tone = dayTone(iso, inM);
          const sel = sameDay(d, selected);
          const isToday = sameDay(d, today);
          const has = hasDayMark(iso, events);
          const dayChips = expanded ? chips.filter((c) => c.date === iso).slice(0, 3) : [];
          return (
            <button
              key={iso}
              type="button"
              tabIndex={interactive ? 0 : -1}
              className={`day-cell ${isToday ? "is-today" : ""} ${sel ? "is-selected" : ""} ${inM ? "" : "is-outside"}`}
              onClick={() => {
                if (!interactive || dragging.current) return;
                goToDate(iso);
                goPage(nav, "/day");
              }}
            >
              <span className="inner">
                {interactive ? <Ripple /> : null}
                {lunar.isSilDay && inM ? <SilMark className="day-cell-buddha" /> : null}
                <span className="lunar-num">{lunar.moonDayKhmer}</span>
                <span className={`day-num ${tone !== "default" && tone !== "muted" ? tone : ""}`}>{d.getDate()}</span>
                {expanded ? null : <span className="lunar-month">{lunar.khmerMonth}</span>}
                {expanded
                  ? dayChips.map((c) => (
                      <span key={c.id} className={`day-chip ${colorKind(c)}`}>
                        {obsTitle(c, lang)}
                      </span>
                    ))
                  : has
                    ? <span className="event-dot" />
                    : null}
              </span>
            </button>
          );
        })}
      </div>
    );
  }

  const offTodayMonth = !sameMonth(cursor, today);

  function openObs(item: Observance) {
    if (item.kind === "event" && item.eventId) {
      setEditId(item.eventId);
      setSheet(true);
      return;
    }
    setInfo(item);
  }

  return (
    <section className="tab-page">
      <header className="flex h-14 shrink-0 items-center gap-1 pr-1 pl-4">
        <button type="button" className="flex min-w-0 flex-1 items-center gap-1 text-left has-ripple" onClick={() => setWheel(true)}>
          <Ripple />
          <span className="text-xl">{formatMonthTitle(cursor, lang)}</span>
          <Icon name="expand_more" />
        </button>
        {offTodayMonth ? (
          <MdIconBtn className="icon-btn" ariaLabel={t(lang, "today")} onClick={() => goToDate(todayIso())}>
            <Icon name="today" />
          </MdIconBtn>
        ) : null}
        <MdIconBtn
          className="icon-btn"
          ariaLabel={expanded ? t(lang, "collapse") : t(lang, "expand")}
          onClick={() => setExpanded((v) => !v)}
        >
          <Icon name={expanded ? "close_fullscreen" : "open_in_full"} />
        </MdIconBtn>
        <MdIconBtn
          className="icon-btn day-add"
          ariaLabel={t(lang, "addTask")}
          onClick={() => {
            setEditId(null);
            setSheet(true);
          }}
        >
          <Icon name="add" />
        </MdIconBtn>
      </header>
      <div className={`cal-body ${expanded ? "is-expanded" : ""}`}>
        {expanded ? null : (
          <div className="cal-lunar flex items-start justify-between gap-3 px-4 pb-2 pt-0.5">
            <p className="min-w-0 text-xs leading-snug text-on-variant">{L.lunarDateText}</p>
            <p className="shrink-0 text-xs text-on-variant">{L.gregorianDateText}</p>
          </div>
        )}
        <div className={`cal-month ${expanded ? "flex min-h-0 flex-1 flex-col overflow-hidden" : ""}`}>
          <div className={`month-view ${expanded ? "is-expanded" : ""}`}>
            <div className="month-weekdays">
              {labels.map((l, i) => (
                <div key={`${l}-${i}`} className={`month-weekday ${i === sunAt ? "is-sunday" : ""}`}>
                  {l}
                </div>
              ))}
            </div>
            <div
              ref={wrap}
              className="month-carousel"
              data-h-pan=""
              onTransitionEnd={(e) => {
                if (e.target !== track.current || e.propertyName !== "transform" || !pending.current) return;
                const dir = pending.current;
                pending.current = 0;
                setCursor(isoOf(addMonths(fromIso(useStore.getState().cursor), dir)));
              }}
            >
              <div ref={track} className="month-track" style={{ transform: "translate3d(-33.333%,0,0)" }}>
                <div className="month-page" aria-hidden>
                  <Grid month={addMonths(cursor, -1)} interactive={false} />
                </div>
                <div className="month-page">
                  <Grid month={cursor} interactive />
                </div>
                <div className="month-page" aria-hidden>
                  <Grid month={addMonths(cursor, 1)} interactive={false} />
                </div>
              </div>
            </div>
          </div>
        </div>
        {expanded ? null : (
          <div className="cal-side">
            <div className="mt-1 flex items-center justify-between px-4 py-2">
              <h2 className="text-base">{t(lang, "events")}</h2>
              <button type="button" className="count-chip has-ripple" onClick={() => goPage(nav, "/events")}>
                <Ripple />
                {holidays.length}
                <Icon name="chevron_right" />
              </button>
            </div>
            <ObsList items={holidays} emptyText={t(lang, "noHolidaysMonth")} selectedDate={selectedIso} onOpen={openObs} lang={lang} />
            <div className="mt-1 flex items-center justify-between px-4 py-2">
              <h2 className="text-base">{t(lang, "tasks")}</h2>
              <button type="button" className="count-chip has-ripple" onClick={() => goPage(nav, "/events")}>
                <Ripple />
                {tasks.length}
                <Icon name="chevron_right" />
              </button>
            </div>
            {tasks.length > 0 ? (
              <ObsList items={tasks} emptyText={t(lang, "noTasksMonth")} selectedDate={selectedIso} onOpen={openObs} lang={lang} />
            ) : (
              <p className="px-5 py-8 text-sm text-on-variant">{t(lang, "noTasksMonth")}</p>
            )}
          </div>
        )}
      </div>
      <Dialog
        open={wheel}
        title={t(lang, "khmerCalendar")}
        closeButton
        onClose={() => setWheel(false)}
        actions={
          <DlgBtn onClick={() => setWheel(false)}>{t(lang, "change")}</DlgBtn>
        }
      >
        <div className="wheel-picker">
          <WheelCol
            kind="month"
            ariaLabel={t(lang, "month")}
            labels={[...months]}
            index={cursor.getMonth()}
            onIndex={(i) => setCursor(isoOf(new Date(cursor.getFullYear(), i, 1)))}
          />
          <WheelCol
            kind="year"
            ariaLabel={t(lang, "year")}
            labels={Array.from({ length: 81 }, (_, i) => String(1970 + i))}
            index={Math.max(0, cursor.getFullYear() - 1970)}
            onIndex={(i) => setCursor(isoOf(new Date(1970 + i, cursor.getMonth(), 1)))}
          />
        </div>
      </Dialog>
      <HolidayInfo open={!!info} item={info} onClose={() => setInfo(null)} />
      <TaskSheet
        open={sheet}
        lang={lang}
        initialDate={selectedIso}
        editing={events.find((e) => e.id === editId) ?? null}
        onClose={() => {
          setSheet(false);
          setEditId(null);
        }}
        onSave={(e) => {
          const exists = events.some((x) => x.id === e.id);
          exists ? updateEvent(e) : addEvent(e);
        }}
        onDelete={deleteEvent}
      />
    </section>
  );
}
