import { useEffect, useLayoutEffect, useRef, useState, type PointerEvent as ReactPointerEvent, type RefObject } from "react";
import { createPortal } from "react-dom";

const SHOW_MS = 500;
const LONG_MS = 500;
const TOUCH_HIDE_MS = 1500;
const LEAVE_MS = 80;
const EDGE = 8;

export type TipPlacement = "above" | "below" | "right";

export type TipState = {
  label: string;
  x: number;
  y: number;
  placement: TipPlacement;
  anchorX: number;
  anchorY: number;
  anchorBottom: number;
};

export type TooltipHandlers = {
  onPointerEnter: (e: ReactPointerEvent<HTMLElement>) => void;
  onPointerLeave: () => void;
  onPointerDown: (e: ReactPointerEvent<HTMLElement>) => void;
  onPointerUp: (e: ReactPointerEvent<HTMLElement>) => void;
  onPointerCancel: () => void;
  onBlur: () => void;
  onFocus: (e: React.FocusEvent<HTMLElement>) => void;
  onClick: () => void;
};

const hideAll = new Set<() => void>();

function broadcastHide() {
  for (const fn of hideAll) fn();
}

function place(rect: DOMRect, mode: "icon" | "nav"): Omit<TipState, "label"> {
  const wide = mode === "nav" && window.matchMedia("(min-width: 840px)").matches;
  return {
    x: wide ? rect.right : rect.left + rect.width / 2,
    y: wide ? rect.top + rect.height / 2 : rect.top,
    anchorX: rect.left + rect.width / 2,
    anchorY: rect.top + rect.height / 2,
    anchorBottom: rect.bottom,
    placement: wide ? "right" : "above",
  };
}

export function useM3Tooltip(opts?: { mode?: "icon" | "nav"; boxSelector?: string }) {
  const mode = opts?.mode ?? "icon";
  const boxSelector = opts?.boxSelector;
  const hoverTimer = useRef(0);
  const pressTimer = useRef(0);
  const hideTimer = useRef(0);
  const longPress = useRef(false);
  const shownOnce = useRef(false);
  const skipHide = useRef(false);
  const [tip, setTip] = useState<TipState | null>(null);
  const tipRef = useRef<HTMLDivElement>(null);

  function clearTimers() {
    window.clearTimeout(hoverTimer.current);
    window.clearTimeout(pressTimer.current);
    window.clearTimeout(hideTimer.current);
  }

  const hideNowRef = useRef<() => void>(() => {});

  function hideNow() {
    if (skipHide.current) return;
    clearTimers();
    shownOnce.current = false;
    longPress.current = false;
    setTip(null);
  }
  hideNowRef.current = hideNow;

  function hideSoon(delay = 0) {
    window.clearTimeout(hideTimer.current);
    hideTimer.current = window.setTimeout(() => {
      shownOnce.current = false;
      longPress.current = false;
      setTip(null);
    }, delay);
  }

  useEffect(() => {
    const proxy = () => hideNowRef.current();
    hideAll.add(proxy);
    return () => {
      hideAll.delete(proxy);
      clearTimers();
    };
  }, []);

  function show(anchor: HTMLElement, label: string) {
    if (!label) return;
    const box = (boxSelector ? anchor.querySelector(boxSelector) : null) ?? anchor;
    const next: TipState = { label, ...place(box.getBoundingClientRect(), mode) };
    skipHide.current = true;
    broadcastHide();
    skipHide.current = false;
    shownOnce.current = true;
    setTip(next);
  }

  function bind(label: string): TooltipHandlers {
    return {
      onPointerEnter: (e: ReactPointerEvent<HTMLElement>) => {
        if (e.pointerType !== "mouse") return;
        clearTimers();
        const el = e.currentTarget;
        const wait = shownOnce.current ? 0 : SHOW_MS;
        hoverTimer.current = window.setTimeout(() => show(el, label), wait);
      },
      onPointerLeave: () => {
        window.clearTimeout(hoverTimer.current);
        window.clearTimeout(pressTimer.current);
        longPress.current = false;
        hideSoon(LEAVE_MS);
      },
      onPointerDown: (e: ReactPointerEvent<HTMLElement>) => {
        if (e.pointerType === "mouse") return;
        longPress.current = false;
        const el = e.currentTarget;
        pressTimer.current = window.setTimeout(() => {
          longPress.current = true;
          show(el, label);
        }, LONG_MS);
      },
      onPointerUp: (e: ReactPointerEvent<HTMLElement>) => {
        window.clearTimeout(pressTimer.current);
        if (longPress.current && e.pointerType !== "mouse") hideSoon(TOUCH_HIDE_MS);
      },
      onPointerCancel: () => hideNow(),
      onBlur: () => hideNow(),
      onFocus: (e: React.FocusEvent<HTMLElement>) => {
        if (!e.currentTarget.matches(":focus-visible")) return;
        const el = e.currentTarget;
        hoverTimer.current = window.setTimeout(() => show(el, label), SHOW_MS);
      },
      onClick: () => {
        if (longPress.current) return;
        hideNow();
      },
    };
  }

  useLayoutEffect(() => {
    const el = tipRef.current;
    if (!el || !tip) return;
    const box = el.getBoundingClientRect();
    if (tip.placement === "right") {
      const half = box.height / 2;
      const min = EDGE + half;
      const max = window.innerHeight - EDGE - half;
      const y = Math.min(max, Math.max(min, tip.anchorY));
      if (Math.abs(y - tip.y) > 0.5) setTip((t) => (t ? { ...t, y } : t));
      return;
    }
    const half = box.width / 2;
    const min = EDGE + half;
    const max = window.innerWidth - EDGE - half;
    const x = Math.min(max, Math.max(min, tip.anchorX));
    const flip = tip.placement === "above" && box.top < EDGE;
    if (Math.abs(x - tip.x) > 0.5 || flip) {
      setTip((t) =>
        t
          ? {
              ...t,
              x,
              placement: flip ? "below" : t.placement,
              y: flip ? t.anchorBottom : t.y,
            }
          : t,
      );
    }
  }, [tip]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") hideNow();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return { tip, tipRef, bind, hideNow, longPress };
}

export function M3Tooltip({
  tip,
  tipRef,
  id,
}: {
  tip: TipState | null;
  tipRef: RefObject<HTMLDivElement | null>;
  id?: string;
}) {
  if (!tip || typeof document === "undefined") return null;
  return createPortal(
    <div
      ref={tipRef}
      id={id}
      className={`m3-tooltip ${tip.placement === "below" ? "is-below" : ""} ${tip.placement === "right" ? "is-right" : ""}`}
      role="tooltip"
      style={{ left: tip.x, top: tip.y }}
    >
      {tip.label}
    </div>,
    document.body,
  );
}
