import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState } from "react";
import { Icon } from "../components/icon";
import { Dialog } from "../components/dialog";
import { TaskSheet } from "../components/task-sheet";
import { MdCheck, MdIconBtn } from "../components/md-click";
import { Ripple } from "../components/ripple";
import { HolidayInfo } from "../components/holiday-info";
import { useStore } from "../lib/store";
import { t, monthsOf, weekdaysFull, type Lang } from "../lib/i18n";
import { eventWhenLabel, eventWhenTone, fromIso, isoOf, todayIso } from "../lib/dates";
import { colorKind, obsTitle, yearObservances, type Observance } from "../lib/observances";

export const Route = createFileRoute("/events")({ component: EventsPage });

type Pane = "holidays" | "tasks";
type TabsEl = HTMLElement & { activeTabIndex?: number };

function EventsTabs({ value, onChange, lang }: { value: Pane; onChange: (v: Pane) => void; lang: Lang }) {
  const ref = useRef<TabsEl | null>(null);
  useEffect(() => {
    const n = ref.current;
    if (!n) return;
    let dead = false;
    customElements.whenDefined("md-tabs").then(() => {
      if (dead || !ref.current) return;
      ref.current.activeTabIndex = value === "tasks" ? 1 : 0;
    });
    const onTab = () => {
      onChange((ref.current?.activeTabIndex ?? 0) === 1 ? "tasks" : "holidays");
    };
    n.addEventListener("change", onTab);
    return () => {
      dead = true;
      n.removeEventListener("change", onTab);
    };
  }, [value, onChange]);
  return (
    <md-tabs ref={ref} className="events-tabs" aria-label={t(lang, "events")}>
      <md-primary-tab active={value === "holidays" || undefined}>{t(lang, "holidaysTab")}</md-primary-tab>
      <md-primary-tab active={value === "tasks" || undefined}>{t(lang, "tasksTab")}</md-primary-tab>
    </md-tabs>
  );
}

function EventsPage() {
  const lang = useStore((s) => s.lang);
  const cursor = useStore((s) => s.cursor);
  const events = useStore((s) => s.events);
  const pane = useStore((s) => s.lastEventsPane);
  const setPane = useStore((s) => s.setLastEventsPane);
  const setCursor = useStore((s) => s.setCursor);
  const toggle = useStore((s) => s.toggleEventDone);
  const addEvent = useStore((s) => s.addEvent);
  const updateEvent = useStore((s) => s.updateEvent);
  const deleteEvent = useStore((s) => s.deleteEvent);
  const year = fromIso(cursor).getFullYear();
  const nowYear = new Date().getFullYear();
  const [pickYear, setPickYear] = useState(false);
  const [sheet, setSheet] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [info, setInfo] = useState<Observance | null>(null);
  const [openGroups, setOpenGroups] = useState({ current: true, overdue: true, done: true });
  const hols = useMemo(() => yearObservances(year, []).filter((e) => e.kind === "holiday"), [year]);
  const groups = useMemo(() => {
    const m = new Map<string, typeof hols>();
    for (const h of hols) {
      const k = h.date.slice(0, 7);
      const arr = m.get(k) ?? [];
      arr.push(h);
      m.set(k, arr);
    }
    return [...m.entries()];
  }, [hols]);
  const today = todayIso();
  const current = events.filter((e) => !e.done && (!e.date || e.date >= today));
  const overdue = events.filter((e) => !e.done && e.date && e.date < today);
  const done = events.filter((e) => e.done);
  const editing = events.find((e) => e.id === editId) ?? null;
  const months = monthsOf(lang);
  const wdays = weekdaysFull(lang);
  const yearOpts = [
    { id: "prev", year: nowYear - 1, label: t(lang, "yearPrev") },
    { id: "now", year: nowYear, label: t(lang, "yearNow") },
    { id: "next", year: nowYear + 1, label: t(lang, "yearNext") },
  ];

  function openHoliday(item: Observance) {
    setInfo(item);
  }

  return (
    <section className="tab-page">
      <header className="events-head">
        <h1>{t(lang, "events")}</h1>
        {pane === "holidays" ? (
          <button type="button" className="events-year has-ripple" onClick={() => setPickYear(true)}>
            <Ripple />
            <span>{year}</span>
            <Icon name="expand_more" />
          </button>
        ) : (
          <MdIconBtn
            className="icon-btn"
            ariaLabel={t(lang, "addTask")}
            onClick={() => {
              setEditId(null);
              setSheet(true);
            }}
          >
            <Icon name="add" />
          </MdIconBtn>
        )}
      </header>
      <EventsTabs value={pane} onChange={setPane} lang={lang} />
      {pane === "holidays" ? (
        <div className="events-groups min-h-0 flex-1 overflow-auto pb-3">
          {groups.length === 0 ? (
            <p className="px-5 py-8 text-sm text-on-variant">{t(lang, "noHolidaysYear")}</p>
          ) : (
            groups.map(([k, list]) => {
              const d = fromIso(`${k}-01`);
              return (
                <section className="hol-group" key={k}>
                  <h2 className="hol-group-title">
                    {d.getFullYear()} {months[d.getMonth()]}
                  </h2>
                  {list.map((h) => {
                    const dt = fromIso(h.date);
                    const tone = colorKind(h);
                    return (
                      <button
                        type="button"
                        className="hol-row has-ripple"
                        key={h.id}
                        onClick={() => openHoliday(h)}
                      >
                        <Ripple />
                        <span className={`hol-num ${tone}`}>{String(dt.getDate()).padStart(2, "0")}</span>
                        <span className="hol-wday">{wdays[dt.getDay()]}</span>
                        <span className="hol-title">{obsTitle(h, lang)}</span>
                      </button>
                    );
                  })}
                </section>
              );
            })
          )}
        </div>
      ) : (
        <div className="events-tasks min-h-0 flex-1 overflow-auto pb-3">
          {events.length === 0 ? (
            <p className="px-5 py-8 text-sm text-on-variant">{t(lang, "noTasks")}</p>
          ) : (
            <>
              <TaskGroup
                title={t(lang, "currentTasks")}
                items={current}
                open={openGroups.current}
                onToggle={() => setOpenGroups((g) => ({ ...g, current: !g.current }))}
                lang={lang}
                onOpen={(id) => {
                  setEditId(id);
                  setSheet(true);
                }}
                onCheck={toggle}
              />
              <TaskGroup
                title={t(lang, "overdue")}
                items={overdue}
                open={openGroups.overdue}
                onToggle={() => setOpenGroups((g) => ({ ...g, overdue: !g.overdue }))}
                lang={lang}
                onOpen={(id) => {
                  setEditId(id);
                  setSheet(true);
                }}
                onCheck={toggle}
              />
              <TaskGroup
                title={t(lang, "completed")}
                items={done}
                open={openGroups.done}
                onToggle={() => setOpenGroups((g) => ({ ...g, done: !g.done }))}
                lang={lang}
                onOpen={(id) => {
                  setEditId(id);
                  setSheet(true);
                }}
                onCheck={toggle}
              />
            </>
          )}
        </div>
      )}
      <Dialog open={pickYear} title={t(lang, "pickYear")} closeButton onClose={() => setPickYear(false)}>
        <div className="year-opts">
          {yearOpts.map((opt) => {
            const on = opt.year === year;
            return (
              <button
                type="button"
                key={opt.id}
                className={`year-opt has-ripple ${on ? "is-on" : ""}`}
                onClick={() => {
                  const cur = fromIso(cursor);
                  setCursor(isoOf(new Date(opt.year, cur.getMonth(), 1)));
                  setPickYear(false);
                }}
              >
                <Ripple />
                <span>{opt.label}</span>
                <span className={`year-radio ${on ? "is-on" : ""}`}>{on ? <Icon name="check" filled /> : null}</span>
              </button>
            );
          })}
        </div>
      </Dialog>
      <HolidayInfo open={!!info} item={info} onClose={() => setInfo(null)} />
      <TaskSheet
        open={sheet}
        lang={lang}
        initialDate={today}
        editing={editing}
        onClose={() => setSheet(false)}
        onSave={(e) => (editing ? updateEvent(e) : addEvent(e))}
        onDelete={deleteEvent}
      />
    </section>
  );
}

function TaskGroup({
  title,
  items,
  open,
  onToggle,
  lang,
  onOpen,
  onCheck,
}: {
  title: string;
  items: ReturnType<typeof useStore.getState>["events"];
  open: boolean;
  onToggle: () => void;
  lang: Lang;
  onOpen: (id: string) => void;
  onCheck: (id: string) => void;
}) {
  if (!items.length) return null;
  return (
    <section className="task-group">
      <button type="button" className="task-group-head has-ripple" onClick={onToggle}>
        <Ripple />
        <span>{title}</span>
        <span className="task-count">
          {items.length}
          <Icon name={open ? "expand_less" : "expand_more"} />
        </span>
      </button>
      {open
        ? items.map((e) => {
            const when = eventWhenLabel(e.date, e.startTime, e.allDay, lang);
            const tone = eventWhenTone(e.date, e.done);
            return (
              <div key={e.id} className={`task-row ${e.done ? "is-done" : ""}`}>
                <MdCheck
                  className="task-check"
                  checked={!!e.done}
                  onChange={() => onCheck(e.id)}
                  ariaLabel={e.done ? t(lang, "undone") : t(lang, "done")}
                />
                <button type="button" className="task-copy has-ripple" onClick={() => onOpen(e.id)}>
                  <Ripple />
                  <span className="task-name">{e.title}</span>
                  {when ? <span className={`task-when ${tone}`}>{when}</span> : null}
                </button>
              </div>
            );
          })
        : null}
    </section>
  );
}
