import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { t, type Lang } from "../lib/i18n";
import { Icon } from "./icon";
import { ConfirmDelete } from "./dialog";
import { MdBtn, MdIconBtn } from "./md-click";
import type { CalendarEvent } from "../lib/store";
import { newId } from "../lib/store";
import { joinTitleNotes, formatTime12, reminderChipLabel, showNativePicker, splitTitleNotes } from "../lib/dates";

function SlideLayer({
  open,
  className,
  children,
  onClose,
}: {
  open: boolean;
  className?: string;
  children: React.ReactNode;
  onClose: () => void;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [mounted, setMounted] = useState(open);
  const [shown, setShown] = useState(false);
  const [drag, setDrag] = useState(false);
  const [x, setX] = useState(0);
  const start = useRef<{ x: number; y: number; axis: "h" | "v" | null } | null>(null);
  const cur = useRef(0);

  useEffect(() => {
    if (open) {
      setMounted(true);
      const id = requestAnimationFrame(() => setShown(true));
      return () => cancelAnimationFrame(id);
    }
    setShown(false);
    setDrag(false);
    const t = window.setTimeout(() => {
      setMounted(false);
      setX(0);
      cur.current = 0;
    }, 180);
    return () => window.clearTimeout(t);
  }, [open]);

  if (!mounted || typeof document === "undefined") return null;

  const slide = shown ? `${x}px` : "100%";

  return createPortal(
    <div
      ref={ref}
      className={`slide-layer ${className ?? ""} ${shown ? "is-open" : ""} ${drag ? "is-dragging" : ""}`}
      style={{ "--slide-x": slide } as React.CSSProperties}
      onPointerDown={(e) => {
        if (!shown) return;
        if (e.pointerType === "mouse" && e.button !== 0) return;
        const t = e.target as HTMLElement;
        if (t.closest("[data-h-pan], input, textarea, select")) return;
        start.current = { x: e.clientX, y: e.clientY, axis: null };
      }}
      onPointerMove={(e) => {
        const s = start.current;
        if (!s) return;
        const dx = e.clientX - s.x;
        const dy = e.clientY - s.y;
        if (!s.axis) {
          if (Math.abs(dx) < 10 && Math.abs(dy) < 10) return;
          s.axis = Math.abs(dx) > Math.abs(dy) ? "h" : "v";
          if (s.axis === "h") {
            e.currentTarget.setPointerCapture(e.pointerId);
            setDrag(true);
          }
        }
        if (s.axis !== "h") return;
        const n = Math.max(0, dx);
        cur.current = n;
        setX(n);
      }}
      onPointerUp={() => {
        const s = start.current;
        start.current = null;
        if (s?.axis !== "h") {
          setDrag(false);
          return;
        }
        const w = ref.current?.clientWidth ?? 1;
        setDrag(false);
        if (cur.current > w * 0.18) {
          onClose();
          return;
        }
        cur.current = 0;
        setX(0);
      }}
      onPointerCancel={() => {
        start.current = null;
        setDrag(false);
        cur.current = 0;
        setX(0);
      }}
    >
      {children}
    </div>,
    document.body,
  );
}

export function TaskSheet({
  open,
  lang,
  initialDate,
  initialTime,
  editing,
  onClose,
  onSave,
  onDelete,
}: {
  open: boolean;
  lang: Lang;
  initialDate: string;
  initialTime?: string;
  editing?: CalendarEvent | null;
  onClose: () => void;
  onSave: (e: CalendarEvent) => void;
  onDelete?: (id: string) => void;
}) {
  const titleRef = useRef<HTMLTextAreaElement>(null);
  const dateRef = useRef<HTMLInputElement>(null);
  const timeRef = useRef<HTMLInputElement>(null);
  const [body, setBody] = useState("");
  const [date, setDate] = useState("");
  const [time, setTime] = useState("");
  const [askDel, setAskDel] = useState(false);
  const isEdit = !!editing;
  const canSave = body.trim().length > 0;
  const hasDate = !!date;

  useEffect(() => {
    if (!open) return;
    setBody(editing ? joinTitleNotes(editing.title, editing.notes) : "");
    const nextDate = editing?.date || initialDate;
    const nextTime = editing ? (editing.allDay ? "" : editing.startTime || editing.reminderTime || "") : initialTime || "";
    setDate(nextDate);
    setTime(nextTime);
    setAskDel(false);
    window.setTimeout(() => titleRef.current?.focus(), 40);
  }, [open, editing, initialDate, initialTime]);

  function save() {
    const { title, notes } = splitTitleNotes(body);
    if (!title) return;
    const id = editing?.id ?? newId();
    onSave({
      ...editing,
      id,
      title,
      notes,
      date,
      endDate: date,
      allDay: !time,
      startTime: time || "09:00",
      endTime: time || "10:00",
      reminderDate: date,
      reminderTime: time,
      done: editing?.done ?? false,
    });
    onClose();
  }

  return (
    <SlideLayer open={open} className="task-sheet" onClose={onClose}>
      <header className="task-head">
        <MdIconBtn className="icon-btn" ariaLabel={t(lang, "back")} onClick={onClose}>
          <Icon name="arrow_back" />
        </MdIconBtn>
        <h1>{t(lang, "task")}</h1>
        {isEdit && onDelete ? (
          <MdIconBtn className="icon-btn is-danger" ariaLabel={t(lang, "delete")} onClick={() => setAskDel(true)}>
            <Icon name="delete" />
          </MdIconBtn>
        ) : (
          <span className="w-12" />
        )}
      </header>
      <textarea
        ref={titleRef}
        className="task-body"
        placeholder={t(lang, "titlePlaceholder")}
        autoComplete="off"
        enterKeyHint="enter"
        rows={8}
        value={body}
        data-selectable=""
        onChange={(e) => setBody(e.target.value)}
      />
      <div className="task-foot">
        <div className="task-chips">
          <MdBtn tag={hasDate ? "md-filled-tonal-button" : "md-outlined-button"} className="task-chip" hasIcon onClick={() => showNativePicker(dateRef.current)}>
            <md-icon slot="icon">schedule</md-icon>
            {reminderChipLabel(date, time, lang)}
          </MdBtn>
          {hasDate ? (
            <MdBtn tag="md-outlined-button" className="task-chip" hasIcon onClick={() => showNativePicker(timeRef.current)}>
              <md-icon slot="icon">alarm</md-icon>
              {time ? formatTime12(time) : t(lang, "time")}
            </MdBtn>
          ) : null}
          {hasDate ? (
            <MdIconBtn
              outlined
              className="task-chip-close"
              ariaLabel={t(lang, "clearReminder")}
              onClick={() => {
                setDate("");
                setTime("");
              }}
            >
              <md-icon>close</md-icon>
            </MdIconBtn>
          ) : null}
          <input
            ref={dateRef}
            className="native-picker-sr"
            type="date"
            value={date}
            tabIndex={-1}
            aria-hidden="true"
            onChange={(e) => setDate(e.target.value)}
          />
          <input
            ref={timeRef}
            className="native-picker-sr"
            type="time"
            value={time}
            tabIndex={-1}
            aria-hidden="true"
            onChange={(e) => setTime(e.target.value)}
          />
        </div>
        <MdBtn tag="md-filled-button" className="task-save" wide disabled={!canSave} onClick={save}>
          {isEdit ? t(lang, "save") : t(lang, "createTask")}
        </MdBtn>
      </div>
      <ConfirmDelete
        open={askDel}
        lang={lang}
        onCancel={() => setAskDel(false)}
        onDelete={() => {
          if (editing && onDelete) onDelete(editing.id);
          setAskDel(false);
          onClose();
        }}
      />
    </SlideLayer>
  );
}
