import { HeadContent, Outlet, Scripts, createRootRoute, useLocation, useRouterState } from "@tanstack/react-router";
import { useEffect, useRef, useState } from "react";
import appCss from "../styles.css?url";
import { AuthProvider } from "@/lib/auth/provider";
import { PreviewHostBridge } from "@/components/preview-host-bridge";
import { loadMaterial } from "../lib/material";
import { useHydrateStore, useStore, type TabId } from "../lib/store";
import { NavBar } from "../components/nav";
import { Dialog, DlgBtn } from "../components/dialog";
import { BootSplash } from "../components/boot-splash";
import { t } from "../lib/i18n";
import { nowHm, todayIso } from "../lib/dates";
import { setNavDir } from "../lib/nav";

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1, viewport-fit=cover" },
      { name: "theme-color", content: "#9A3B38" },
      { name: "mobile-web-app-capable", content: "yes" },
      { name: "apple-mobile-web-app-capable", content: "yes" },
      { name: "apple-mobile-web-app-title", content: "ប្រតិទិនខ្មែរ" },
      { title: "ប្រតិទិនខ្មែរ" },
    ],
    links: [
      { rel: "stylesheet", href: "/apk-app.css" },
      { rel: "stylesheet", href: appCss },
      { rel: "icon", href: "/favicon.svg", type: "image/svg+xml" },
      { rel: "apple-touch-icon", href: "/apple-touch-icon.png" },
      { rel: "manifest", href: "/__grok/manifest.webmanifest" },
    ],
  }),
  component: RootDocument,
});

const TAB_PATH: Record<string, TabId> = {
  "/day": "today",
  "/months": "months",
  "/events": "events",
  "/weather": "weather",
  "/more": "more",
};

function RootDocument() {
  return (
    <html lang="km" suppressHydrationWarning>
      <head>
        <HeadContent />
      </head>
      <body>
        <PreviewHostBridge />
        <AuthProvider>
          <Root />
        </AuthProvider>
        <Scripts />
      </body>
    </html>
  );
}

function PageSpinner({ show, label }: { show: boolean; label: string }) {
  const ref = useRef<HTMLElement>(null);
  useEffect(() => {
    if (!show) return;
    const n = ref.current as (HTMLElement & { indeterminate?: boolean }) | null;
    customElements.whenDefined("md-circular-progress").then(() => {
      if (ref.current) (ref.current as HTMLElement & { indeterminate?: boolean }).indeterminate = true;
    });
    if (n) n.indeterminate = true;
  }, [show]);
  if (!show) return null;
  return (
    <div className="page-spinner" role="status" aria-live="polite" aria-label={label}>
      <md-circular-progress ref={ref} indeterminate aria-label={label} />
    </div>
  );
}

function Root() {
  useHydrateStore();
  const loc = useLocation();
  const status = useRouterState({ select: (s) => s.status });
  const lang = useStore((s) => s.lang);
  const hydrated = useStore((s) => s.hydrated);
  const notifyOn = useStore((s) => s.notifyOn);
  const events = useStore((s) => s.events);
  const setLastTab = useStore((s) => s.setLastTab);
  const lastTab = useStore((s) => s.lastTab);
  const paintTheme = useStore((s) => s.paintTheme);
  const [exit, setExit] = useState(false);
  const [booted, setBooted] = useState(false);
  const [spin, setSpin] = useState(false);
  const fired = useRef(new Set<string>());
  const spinUntil = useRef(0);

  const path = loc.pathname;
  const tab = TAB_PATH[path];
  const isSetup = path.startsWith("/get-started");
  const isOverlay = path.startsWith("/settings") || path.startsWith("/tools") || path === "/download";
  const ready = hydrated && booted;

  useEffect(() => {
    void loadMaterial();
    paintTheme();
    document.documentElement.classList.add("no-select", "is-booting");
    if (typeof document.startViewTransition !== "function") {
      document.documentElement.classList.add("no-vt");
    }
    const block = (e: Event) => e.preventDefault();
    document.addEventListener("contextmenu", block);
    document.addEventListener("dragstart", block);
    const onBIP = (e: Event) => {
      e.preventDefault();
      (window as Window & { deferredPrompt?: Event }).deferredPrompt = e;
    };
    window.addEventListener("beforeinstallprompt", onBIP);
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    const onScheme = () => useStore.getState().paintTheme();
    mq.addEventListener("change", onScheme);
    return () => {
      document.removeEventListener("contextmenu", block);
      document.removeEventListener("dragstart", block);
      window.removeEventListener("beforeinstallprompt", onBIP);
      mq.removeEventListener("change", onScheme);
    };
  }, [paintTheme]);

  useEffect(() => {
    if (ready) document.documentElement.classList.remove("is-booting");
    else document.documentElement.classList.add("is-booting");
  }, [ready]);

  useEffect(() => {
    if (tab) setLastTab(tab);
  }, [tab, setLastTab]);

  useEffect(() => {
    if (status === "pending") {
      spinUntil.current = Date.now() + 240;
      setSpin(true);
      return;
    }
    const left = spinUntil.current - Date.now();
    if (left <= 0) {
      setSpin(false);
      return;
    }
    const id = window.setTimeout(() => setSpin(false), left);
    return () => window.clearTimeout(id);
  }, [status]);

  useEffect(() => {
    const onPop = () => {
      setNavDir("back");
      if (isOverlay || isSetup) return;
      setExit(true);
      history.pushState(null, "", loc.href);
    };
    window.addEventListener("popstate", onPop);
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !isSetup && !isOverlay) setExit(true);
    };
    window.addEventListener("keydown", onKey);
    return () => {
      window.removeEventListener("popstate", onPop);
      window.removeEventListener("keydown", onKey);
    };
  }, [isOverlay, isSetup, loc.href]);

  useEffect(() => {
    if (!notifyOn || typeof Notification === "undefined") return;
    const tick = () => {
      if (Notification.permission !== "granted") return;
      const iso = todayIso();
      const hm = nowHm();
      for (const e of events) {
        if (!e.reminderDate || !e.reminderTime || e.done) continue;
        if (e.reminderDate !== iso || e.reminderTime !== hm) continue;
        const key = `${e.id}-${e.reminderDate}-${e.reminderTime}`;
        if (fired.current.has(key)) continue;
        fired.current.add(key);
        try {
          new Notification(`${t(lang, "reminderPrefix")}: ${e.title}`, {
            body: e.notes || e.title,
            icon: "/icon-192.png",
          });
        } catch {
          /* web */
        }
      }
    };
    tick();
    const id = window.setInterval(tick, 20000);
    return () => window.clearInterval(id);
  }, [notifyOn, events, lang]);

  const showNav = ready && !isSetup;

  return (
    <>
      {hydrated ? (
        <div className={`md-shell ${path.startsWith("/weather") ? "is-wx" : ""}`} data-tab={tab ?? lastTab}>
          <div className="tab-stage">
            <Outlet />
          </div>
          {showNav ? <NavBar active={tab ?? lastTab ?? "more"} lang={lang} /> : null}
          <PageSpinner show={spin} label={t(lang, "loading")} />
          <Dialog
            open={exit}
            title={t(lang, "exitTitle")}
            onClose={() => setExit(false)}
            actions={
              <>
                <DlgBtn secondary onClick={() => setExit(false)}>
                  {t(lang, "stay")}
                </DlgBtn>
                <DlgBtn
                  onClick={() => {
                    setExit(false);
                    window.close();
                    history.back();
                  }}
                >
                  {t(lang, "exit")}
                </DlgBtn>
              </>
            }
          >
            <p>{t(lang, "exitBody")}</p>
          </Dialog>
        </div>
      ) : null}
      {!ready ? <BootSplash lang={lang} onDone={() => setBooted(true)} /> : null}
    </>
  );
}
