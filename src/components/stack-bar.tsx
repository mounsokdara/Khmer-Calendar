import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";

export function StackBar({
  open,
  message,
  onDismiss,
  autoHideDuration = 4000,
  className = "",
}: {
  open: boolean;
  message: string;
  onDismiss?: () => void;
  autoHideDuration?: number;
  className?: string;
}) {
  const [translateY, setTranslateY] = useState(200);
  const [shown, setShown] = useState(open);
  const timeout = useRef<number | null>(null);
  const innerRef = useRef<HTMLDivElement>(null);
  const dragging = useRef(false);
  const startY = useRef(0);
  const startOff = useRef(0);
  const off = useRef(200);
  const dismissRef = useRef(onDismiss);
  dismissRef.current = onDismiss;
  off.current = translateY;

  const clear = () => {
    if (timeout.current != null) {
      window.clearTimeout(timeout.current);
      timeout.current = null;
    }
  };

  const dismiss = () => {
    clear();
    setTranslateY(200);
    window.setTimeout(() => {
      setShown(false);
      dismissRef.current?.();
    }, 300);
  };

  useEffect(() => {
    if (!open) {
      if (shown) {
        clear();
        setTranslateY(200);
        const id = window.setTimeout(() => setShown(false), 300);
        return () => window.clearTimeout(id);
      }
      return;
    }
    setShown(true);
    setTranslateY(200);
    const frame = requestAnimationFrame(() => setTranslateY(0));
    clear();
    timeout.current = window.setTimeout(() => dismiss(), autoHideDuration);
    return () => {
      cancelAnimationFrame(frame);
      clear();
    };
  }, [open, autoHideDuration, message]);

  const down = (e: React.PointerEvent) => {
    if (!innerRef.current) return;
    dragging.current = true;
    startY.current = e.clientY;
    startOff.current = off.current;
    innerRef.current.style.transition = "none";
    clear();
    e.preventDefault();
    e.currentTarget.setPointerCapture(e.pointerId);
  };
  const move = (e: React.PointerEvent) => {
    if (!dragging.current) return;
    const next = Math.max(startOff.current + (e.clientY - startY.current), 0);
    off.current = next;
    setTranslateY(next);
  };
  const up = (e: React.PointerEvent) => {
    if (!dragging.current) return;
    dragging.current = false;
    if (innerRef.current) innerRef.current.style.transition = "";
    if (off.current > 24) dismiss();
    else {
      setTranslateY(0);
      clear();
      timeout.current = window.setTimeout(() => dismiss(), autoHideDuration);
    }
    if (e.currentTarget.hasPointerCapture(e.pointerId)) e.currentTarget.releasePointerCapture(e.pointerId);
  };

  if (!shown || !message || typeof document === "undefined") return null;
  return createPortal(
    <div className={`stack-bar ${className}`} role="status" aria-live="polite">
      <div
        ref={innerRef}
        className="stack-bar-inner"
        style={{
          transform: `translateY(${translateY}px)`,
          transition: dragging.current ? "none" : "transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)",
        }}
        onPointerDown={down}
        onPointerMove={move}
        onPointerUp={up}
        onPointerCancel={up}
      >
        <span className="stack-bar-msg">{message}</span>
      </div>
    </div>,
    document.body,
  );
}
