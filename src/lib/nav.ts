import type { TabId } from "./store";

export const TAB_ORDER: { id: TabId; to: string }[] = [
  { id: "today", to: "/day" },
  { id: "months", to: "/months" },
  { id: "events", to: "/events" },
  { id: "weather", to: "/weather" },
  { id: "more", to: "/more" },
];

export function isOverlayPath(path: string) {
  return path === "/download" || path.startsWith("/settings") || path.startsWith("/tools");
}

export function tabFromPath(path: string): TabId {
  const hit = TAB_ORDER.find((t) => t.to === path);
  if (hit) return hit.id;
  if (isOverlayPath(path)) return "more";
  const nested = [...TAB_ORDER].reverse().find((t) => path.startsWith(`${t.to}/`));
  return nested?.id ?? "months";
}

export function setNavDir(dir: "fwd" | "back") {
  if (typeof document === "undefined") return;
  const root = document.documentElement;
  root.dataset.navDir = dir;
  root.dataset.navAnim = "1";
  window.setTimeout(() => {
    if (root.dataset.navAnim === "1") delete root.dataset.navAnim;
  }, 280);
}

export function setTabDir(from: TabId, to: TabId) {
  const a = TAB_ORDER.findIndex((t) => t.id === from);
  const b = TAB_ORDER.findIndex((t) => t.id === to);
  setNavDir(b >= a ? "fwd" : "back");
}

type NavLike = (opts: { to: string; viewTransition?: boolean; replace?: boolean }) => unknown;

export function goPage(nav: NavLike, to: string, dir?: "fwd" | "back") {
  if (typeof window !== "undefined") {
    if (dir) setNavDir(dir);
    else if (isOverlayPath(window.location.pathname)) setNavDir("back");
    else setTabDir(tabFromPath(window.location.pathname), tabFromPath(to));
  }
  return nav({ to, viewTransition: true });
}
