import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState } from "react";
import { Icon } from "../components/icon";
import { SilMark } from "../components/sil-mark";
import { AnimalArt, animalLabel } from "../components/animal";
import { TaskSheet } from "../components/task-sheet";
import { StackBar } from "../components/stack-bar";
import { MdIconBtn } from "../components/md-click";
import { Ripple } from "../components/ripple";
import { useStore } from "../lib/store";
import { t, weekdaysFull } from "../lib/i18n";
import { addDays, fromIso, isoOf, roundTime5, todayIso } from "../lib/dates";
import { animalPair, lunarOf } from "../lib/chhankitek";
import { observancesOn, obsTitle, type Observance } from "../lib/observances";
import { HolidayInfo } from "../components/holiday-info";

export const Route = createFileRoute("/day")({ component: DayPage });

function DayCard({
  day,
  events,
  interactive,
  onOpen,
  onCopy,
  onToggle,
  onHoliday,
}: {
  day: Date;
  events: ReturnType<typeof useStore.getState>["events"];
  interactive: boolean;
  onOpen: (id: string) => void;
  onCopy: (text: string) => void;
  onToggle: (id: string) => void;
  onHoliday: (item: Observance) => void;
}) {
  const lang = useStore((s) => s.lang);
  const iso = isoOf(day);
  const L = lunarOf(day);
  const [a, b] = animalPair(L);
  const items = observancesOn(iso, events, lang);
  const hols = items.filter((i) => i.kind === "holiday");
  const tasks = events.filter((e) => e.date === iso);
  const wdays = weekdaysFull(lang);

  return (
    <article className="day-panel" aria-hidden={!interactive}>
      <h2 className="day-hero">
        {day.getDate()} {wdays[day.getDay()]}
      </h2>
      <section className="day-card">
        <p className="day-lunar">{L.lunarDateText}</p>
        <button type="button" className="day-copy has-ripple" onClick={() => onCopy(L.fullText)}>
          <Ripple />
          {t(lang, "copy")}
        </button>
      </section>
      <section className="day-card day-zodiac">
        <div className="day-animal">
          <AnimalArt animal={a} className="day-animal-art" />
          <span>{animalLabel(a, lang)}</span>
        </div>
        <span className="day-zodiac-x">X</span>
        <div className="day-animal">
          <AnimalArt animal={b} className="day-animal-art" />
          <span>{animalLabel(b, lang)}</span>
        </div>
      </section>
      {hols.map((h) => (
        <button key={h.id} type="button" className="day-card day-holiday-card has-ripple" onClick={() => onHoliday(h)}>
          <Ripple />
          {obsTitle(h, lang)}
        </button>
      ))}
      {tasks.length ? (
        <section className="day-card day-tasks">
          {tasks.map((e) => (
            <div key={e.id} className={`day-task ${e.done ? "is-done" : ""}`}>
              <button
                type="button"
                className="day-check has-ripple"
                aria-pressed={e.done}
                onClick={() => onToggle(e.id)}
              >
                <Ripple />
                {e.done ? <Icon name="check" filled /> : null}
              </button>
              <button type="button" className="day-task-title has-ripple" onClick={() => onOpen(e.id)}>
                <Ripple />
                {e.title}
              </button>
            </div>
          ))}
        </section>
      ) : null}
    </article>
  );
}

function DayPage() {
  const lang = useStore((s) => s.lang);
  const selectedIso = useStore((s) => s.selected);
  const events = useStore((s) => s.events);
  const goToDate = useStore((s) => s.goToDate);
  const toggle = useStore((s) => s.toggleEventDone);
  const addEvent = useStore((s) => s.addEvent);
  const updateEvent = useStore((s) => s.updateEvent);
  const deleteEvent = useStore((s) => s.deleteEvent);
  const selected = fromIso(selectedIso);
  const today = todayIso();
  const isToday = selectedIso === today;
  const L = lunarOf(selected);
  const [sheet, setSheet] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [info, setInfo] = useState<Observance | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const scroller = useRef<HTMLDivElement>(null);
  const days = useMemo(() => Array.from({ length: 21 }, (_, i) => addDays(selected, i - 10)), [selectedIso]);

  useEffect(() => {
    const el = scroller.current;
    if (!el) return;
    const w = el.clientWidth || 1;
    el.scrollTo({ left: 10 * w, behavior: "instant" as ScrollBehavior });
  }, [selectedIso]);

  useEffect(() => {
    const el = scroller.current;
    if (!el) return;
    let tmo = 0;
    const onScroll = () => {
      window.clearTimeout(tmo);
      tmo = window.setTimeout(() => {
        const w = el.clientWidth || 1;
        const i = Math.round(el.scrollLeft / w);
        const d = days[i];
        if (d) goToDate(isoOf(d));
      }, 80);
    };
    el.addEventListener("scroll", onScroll, { passive: true });
    return () => {
      window.clearTimeout(tmo);
      el.removeEventListener("scroll", onScroll);
    };
  }, [days, goToDate]);

  async function copy(text: string) {
    try {
      await navigator.clipboard.writeText(text);
      setToast(t(lang, "copied"));
    } catch {
      try {
        const ta = document.createElement("textarea");
        ta.value = text;
        ta.setAttribute("readonly", "");
        ta.style.position = "fixed";
        ta.style.left = "-9999px";
        document.body.appendChild(ta);
        ta.select();
        document.execCommand("copy");
        ta.remove();
        setToast(t(lang, "copied"));
      } catch {
        setToast(t(lang, "copyFail"));
      }
    }
  }

  const editing = events.find((e) => e.id === editId) ?? null;

  return (
    <section className="tab-page day-page">
      <header className="day-head">
        <div className="day-head-actions">
          {!isToday ? (
            <MdIconBtn className="icon-btn" ariaLabel={t(lang, "today")} onClick={() => goToDate(today)}>
              <Icon name="today" />
            </MdIconBtn>
          ) : null}
          {L.isSilDay ? (
            <span className="day-sil-chip" aria-label={t(lang, "silDay")}>
              <SilMark />
            </span>
          ) : null}
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
        </div>
      </header>
      <div className="day-view">
        <div ref={scroller} className="day-carousel" data-h-pan="">
          <div className="day-track">
            {days.map((d) => (
              <DayCard
                key={isoOf(d)}
                day={d}
                events={events}
                interactive={isoOf(d) === selectedIso}
                onOpen={(id) => {
                  setEditId(id);
                  setSheet(true);
                }}
                onCopy={copy}
                onToggle={toggle}
                onHoliday={(h) => setInfo(h)}
              />
            ))}
          </div>
        </div>
      </div>
      <HolidayInfo open={!!info} item={info} onClose={() => setInfo(null)} />
      <TaskSheet
        open={sheet}
        lang={lang}
        initialDate={selectedIso}
        initialTime={roundTime5()}
        editing={editing}
        onClose={() => setSheet(false)}
        onSave={(e) => (editing ? updateEvent(e) : addEvent(e))}
        onDelete={deleteEvent}
      />
      <StackBar open={!!toast} message={toast ?? ""} onDismiss={() => setToast(null)} />
    </section>
  );
}
