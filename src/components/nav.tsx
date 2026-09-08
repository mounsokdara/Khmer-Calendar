import { useEffect, useRef, useState } from "react";
import { useNavigate, useRouter } from "@tanstack/react-router";
import { t, type Lang } from "../lib/i18n";
import { Icon } from "./icon";
import { Ripple, attachRipple } from "./ripple";
import { M3Tooltip, useM3Tooltip } from "./tooltip";
import type { TabId } from "../lib/store";
import { goPage, isOverlayPath } from "../lib/nav";
import { loadMaterial } from "../lib/material";

const TABS: { id: TabId; to: string; icon: string; label: "navToday" | "navMonth" | "navEvents" | "navWeather" | "navMore" }[] = [
  { id: "today", to: "/day", icon: "today", label: "navToday" },
  { id: "months", to: "/months", icon: "calendar_month", label: "navMonth" },
  { id: "events", to: "/events", icon: "event_note", label: "navEvents" },
  { id: "weather", to: "/weather", icon: "partly_cloudy_day", label: "navWeather" },
  { id: "more", to: "/more", icon: "menu", label: "navMore" },
];

export function NavBar({ active, lang, onTab }: { active: TabId; lang: Lang; onTab?: (id: TabId) => void }) {
  const nav = useNavigate();
  const router = useRouter();
  const tabs = useRef<(HTMLButtonElement | null)[]>([]);
  const [ready, setReady] = useState(false);
  const tip = useM3Tooltip({ mode: "nav", boxSelector: ".m3-nav-indicator" });

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      await loadMaterial();
      await customElements.whenDefined("md-ripple");
      if (cancelled) return;
      tabs.current.forEach((btn) => {
        attachRipple(btn?.querySelector("md-ripple") as HTMLElement | null, btn);
      });
    })();
    const id = window.requestAnimationFrame(() => setReady(true));
    return () => {
      cancelled = true;
      window.cancelAnimationFrame(id);
    };
  }, []);

  return (
    <div className="nav-wrap">
      <nav className={`m3-nav ${ready ? "is-ready" : ""}`} aria-label={t(lang, "navAria")}>
        {TABS.map((tab, i) => {
          const on = tab.id === active;
          const label = t(lang, tab.label);
          const handlers = tip.bind(label);
          const described = tip.tip?.label === label ? "m3-nav-tooltip" : undefined;
          return (
            <button
              key={tab.id}
              id={`nav-tab-${tab.id}`}
              ref={(el) => {
                tabs.current[i] = el;
              }}
              type="button"
              role="tab"
              className={`m3-nav-item ${on ? "is-active" : ""}`}
              aria-selected={on}
              aria-current={on ? "page" : undefined}
              aria-label={label}
              aria-describedby={described}
              onClick={() => {
                handlers.onClick();
                if (tip.longPress.current) return;
                const overlay = isOverlayPath(window.location.pathname);
                if (on && !overlay) return;
                onTab?.(tab.id);
                goPage(nav, tab.to);
              }}
              onContextMenu={(e) => e.preventDefault()}
              onPointerEnter={(e) => {
                void router.preloadRoute({ to: tab.to }).catch(() => undefined);
                handlers.onPointerEnter(e);
              }}
              onPointerLeave={handlers.onPointerLeave}
              onPointerDown={handlers.onPointerDown}
              onPointerUp={handlers.onPointerUp}
              onPointerCancel={handlers.onPointerCancel}
              onBlur={handlers.onBlur}
              onFocus={handlers.onFocus}
            >
              <span className="m3-nav-indicator">
                <Ripple />
                <Icon name={tab.icon} filled={on} />
              </span>
              <span className="m3-nav-label">{label}</span>
            </button>
          );
        })}
      </nav>
      <M3Tooltip tip={tip.tip} tipRef={tip.tipRef} id="m3-nav-tooltip" />
    </div>
  );
}
