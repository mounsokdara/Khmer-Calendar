import { MdBtn, MdIconBtn } from "./md-click";
import { t, type Lang } from "../lib/i18n";
import { Icon } from "./icon";
import { useEffect, useState } from "react";
import { createPortal } from "react-dom";

export function Dialog({
  open,
  title,
  children,
  actions,
  onClose,
  closeButton,
  term,
}: {
  open: boolean;
  title: string;
  children?: React.ReactNode;
  actions?: React.ReactNode;
  onClose: () => void;
  closeButton?: boolean;
  term?: boolean;
}) {
  const [mounted, setMounted] = useState(open);
  const [phase, setPhase] = useState<"enter" | "open" | "leave">(open ? "open" : "enter");

  useEffect(() => {
    if (open) {
      setMounted(true);
      setPhase("enter");
      const id = requestAnimationFrame(() => {
        requestAnimationFrame(() => setPhase("open"));
      });
      return () => cancelAnimationFrame(id);
    }
    setPhase("leave");
    const t = window.setTimeout(() => setMounted(false), 180);
    return () => window.clearTimeout(t);
  }, [open]);

  useEffect(() => {
    if (!mounted) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    window.addEventListener("keydown", onKey);
    return () => {
      document.body.style.overflow = prev;
      window.removeEventListener("keydown", onKey);
    };
  }, [mounted, onClose]);

  if (!mounted || typeof document === "undefined") return null;

  return createPortal(
    <div
      className={`app-dlg ${phase === "open" ? "is-open" : ""} ${phase === "leave" ? "is-leave" : ""} ${term ? "is-term" : ""}`}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className={`app-dlg-card ${term ? "is-term" : ""}`}
        role="dialog"
        aria-modal="true"
        aria-labelledby="app-dlg-title"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="app-dlg-head">
          <h2 id="app-dlg-title" className="app-dlg-title">
            {title}
          </h2>
          {closeButton ? (
            <MdIconBtn className="icon-btn" onClick={onClose} ariaLabel="Close">
              <Icon name="close" />
            </MdIconBtn>
          ) : null}
        </div>
        <div className="app-dlg-body">{children}</div>
        {actions ? <div className="app-dlg-actions">{actions}</div> : null}
      </div>
    </div>,
    document.body,
  );
}

export function DlgBtn({
  children,
  onClick,
  secondary,
  danger,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  secondary?: boolean;
  danger?: boolean;
}) {
  return (
    <MdBtn
      tag={secondary ? "md-outlined-button" : "md-filled-button"}
      className={`dlg-action-btn ${danger ? "is-danger" : ""}`}
      wide
      onClick={onClick}
    >
      {children}
    </MdBtn>
  );
}

export function ConfirmDelete({
  open,
  lang,
  onCancel,
  onDelete,
  title,
}: {
  open: boolean;
  lang: Lang;
  onCancel: () => void;
  onDelete: () => void;
  title?: string;
}) {
  return (
    <Dialog
      open={open}
      title={title ?? t(lang, "confirmDelete")}
      onClose={onCancel}
      actions={
        <>
          <DlgBtn secondary onClick={onCancel}>
            {t(lang, "cancel")}
          </DlgBtn>
          <DlgBtn danger onClick={onDelete}>
            {t(lang, "delete")}
          </DlgBtn>
        </>
      }
    />
  );
}
