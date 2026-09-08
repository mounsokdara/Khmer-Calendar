import { createElement, useEffect, useId, useRef, type ReactNode, type RefObject } from "react";
import { Ripple } from "./ripple";
import { M3Tooltip, useM3Tooltip, type TooltipHandlers } from "./tooltip";

function useHostClick(ref: RefObject<HTMLElement | null>, onClick?: () => void, onChange?: () => void) {
  useEffect(() => {
    const n = ref.current;
    if (!n) return;
    const click = (e: Event) => {
      if (onChange && e.type === "click") return;
      onClick?.();
    };
    const change = () => onChange?.();
    if (onClick) n.addEventListener("click", click);
    if (onChange) n.addEventListener("change", change);
    return () => {
      n.removeEventListener("click", click);
      n.removeEventListener("change", change);
    };
  }, [onClick, onChange, ref]);
}

type BtnTag = "md-filled-button" | "md-outlined-button" | "md-filled-tonal-button" | "md-text-button";

export function MdBtn({
  tag,
  className,
  disabled,
  onClick,
  hasIcon,
  wide,
  children,
}: {
  tag: BtnTag;
  className?: string;
  disabled?: boolean;
  onClick?: () => void;
  hasIcon?: boolean;
  wide?: boolean;
  children?: ReactNode;
}) {
  const ref = useRef<HTMLElement>(null);
  useHostClick(ref, onClick);
  return createElement(
    tag,
    {
      ref,
      className: [className, wide ? "md-wide" : ""].filter(Boolean).join(" ") || undefined,
      type: "button",
      disabled: disabled || undefined,
      "has-icon": hasIcon || undefined,
    },
    children,
  );
}

export function MdIconBtn({
  outlined,
  filled,
  tonal,
  className,
  onClick,
  ariaLabel,
  unbounded,
  children,
}: {
  outlined?: boolean;
  filled?: boolean;
  tonal?: boolean;
  className?: string;
  onClick?: () => void;
  ariaLabel?: string;
  unbounded?: boolean;
  children?: ReactNode;
}) {
  const web = !!(filled || tonal || outlined);
  const hostRef = useRef<HTMLElement>(null);
  const tip = useM3Tooltip({ mode: "icon" });
  const tipId = useId();
  const label = ariaLabel ?? "";
  const tipBind = label ? tip.bind(label) : null;
  const described = tip.tip ? tipId : undefined;

  useHostClick(
    hostRef,
    web
      ? () => {
          if (tip.longPress.current) return;
          tip.hideNow();
          onClick?.();
        }
      : undefined,
  );

  if (web) {
    const tag = filled
      ? "md-filled-icon-button"
      : tonal
        ? "md-filled-tonal-icon-button"
        : "md-outlined-icon-button";
    return (
      <>
        {createElement(
          tag,
          {
            ref: hostRef,
            className: ["md-icon-host", className].filter(Boolean).join(" "),
            type: "button",
            "aria-label": ariaLabel,
            "aria-describedby": described,
            ...(tipBind ?? {}),
          },
          children,
        )}
        {label ? <M3Tooltip tip={tip.tip} tipRef={tip.tipRef} id={tipId} /> : null}
      </>
    );
  }

  const handlers: Partial<TooltipHandlers> = tipBind ?? {};
  return (
    <>
      <button
        type="button"
        className={["icon-btn", "has-ripple", className].filter(Boolean).join(" ")}
        aria-label={ariaLabel}
        aria-describedby={described}
        onClick={(e) => {
          handlers.onClick?.();
          if (tip.longPress.current) {
            e.preventDefault();
            return;
          }
          onClick?.();
        }}
        onPointerEnter={handlers.onPointerEnter}
        onPointerLeave={handlers.onPointerLeave}
        onPointerDown={handlers.onPointerDown}
        onPointerUp={handlers.onPointerUp}
        onPointerCancel={handlers.onPointerCancel}
        onBlur={handlers.onBlur}
        onFocus={handlers.onFocus}
      >
        <Ripple unbounded={unbounded} />
        {children}
      </button>
      {label ? <M3Tooltip tip={tip.tip} tipRef={tip.tipRef} id={tipId} /> : null}
    </>
  );
}

export function MdCheck({
  checked,
  onChange,
  className,
  ariaLabel,
}: {
  checked?: boolean;
  onChange?: () => void;
  className?: string;
  ariaLabel?: string;
}) {
  const ref = useRef<HTMLElement>(null);
  useEffect(() => {
    const n = ref.current as (HTMLElement & { checked?: boolean }) | null;
    if (n) n.checked = !!checked;
  }, [checked]);
  useEffect(() => {
    const n = ref.current;
    if (!n || !onChange) return;
    const stop = (e: Event) => e.stopPropagation();
    const change = () => onChange();
    n.addEventListener("click", stop);
    n.addEventListener("change", change);
    return () => {
      n.removeEventListener("click", stop);
      n.removeEventListener("change", change);
    };
  }, [onChange]);
  return (
    <md-checkbox
      ref={ref}
      className={className}
      checked={checked || undefined}
      touch-target="wrapper"
      aria-label={ariaLabel}
    />
  );
}

export function MdSwitch({
  selected,
  onChange,
  disabled,
  ariaLabel,
}: {
  selected: boolean;
  onChange: () => void;
  disabled?: boolean;
  ariaLabel?: string;
}) {
  const ref = useRef<HTMLElement>(null);
  useEffect(() => {
    const n = ref.current as (HTMLElement & { selected?: boolean }) | null;
    if (n) n.selected = selected;
  }, [selected]);
  useEffect(() => {
    const n = ref.current;
    if (!n) return;
    const stop = (e: Event) => e.stopPropagation();
    const change = () => onChange();
    n.addEventListener("click", stop);
    n.addEventListener("change", change);
    return () => {
      n.removeEventListener("click", stop);
      n.removeEventListener("change", change);
    };
  }, [onChange]);
  return (
    <md-switch
      ref={ref}
      selected={selected || undefined}
      disabled={disabled || undefined}
      aria-label={ariaLabel}
      onClick={(e) => e.stopPropagation()}
    />
  );
}

export function MdSlider({
  min,
  max,
  value,
  disabled,
  labeled,
  onInput,
  ariaLabel,
  className,
}: {
  min: number;
  max: number;
  value: number;
  disabled?: boolean;
  labeled?: boolean;
  onInput: (v: number) => void;
  ariaLabel?: string;
  className?: string;
}) {
  const ref = useRef<HTMLElement>(null);
  useEffect(() => {
    const n = ref.current as (HTMLElement & { value?: number }) | null;
    if (n) n.value = value;
  }, [value]);
  useEffect(() => {
    const n = ref.current;
    if (!n) return;
    const read = () => {
      const v = Number((n as HTMLElement & { value?: number }).value);
      if (Number.isFinite(v)) onInput(v);
    };
    n.addEventListener("input", read);
    n.addEventListener("change", read);
    return () => {
      n.removeEventListener("input", read);
      n.removeEventListener("change", read);
    };
  }, [onInput]);
  return (
    <md-slider
      ref={ref}
      className={className}
      min={min}
      max={max}
      value={value}
      labeled={labeled || undefined}
      disabled={disabled || undefined}
      aria-label={ariaLabel}
    />
  );
}
