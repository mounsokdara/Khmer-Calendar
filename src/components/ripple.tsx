import { useEffect, useRef, type RefObject } from "react";

type MdRippleEl = HTMLElement & {
  attach?: (host: EventTarget) => void;
  unbounded?: boolean;
};

export function attachRipple(ripple: MdRippleEl | null, host: HTMLElement | null) {
  if (!ripple || !host) return;
  if (typeof ripple.attach === "function") {
    ripple.attach(host);
    return;
  }
  if (host.id) ripple.setAttribute("for", host.id);
}

export function Ripple({
  unbounded = false,
  host,
}: {
  unbounded?: boolean;
  host?: RefObject<HTMLElement | null>;
}) {
  const ref = useRef<MdRippleEl>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    let cancelled = false;
    const run = () => {
      if (cancelled) return;
      const fallback =
        (el.closest("button, [role='button'], a, label") as HTMLElement | null) ?? el.parentElement;
      attachRipple(el, host?.current ?? fallback);
    };
    if (customElements.get("md-ripple")) run();
    else customElements.whenDefined("md-ripple").then(run);
    return () => {
      cancelled = true;
    };
  }, [host]);

  return <md-ripple ref={ref} unbounded={unbounded || undefined} />;
}
