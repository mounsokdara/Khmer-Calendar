import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";
import { useStore } from "../lib/store";

export const Route = createFileRoute("/")({ component: IndexRedirect });

const TAB_TO: Record<string, string> = {
  today: "/day",
  months: "/months",
  events: "/events",
  weather: "/weather",
  more: "/more",
};

function IndexRedirect() {
  const nav = useNavigate();
  const setupDone = useStore((s) => s.setupDone);
  const lastTab = useStore((s) => s.lastTab);
  const hydrated = useStore((s) => s.hydrated);
  useEffect(() => {
    if (!hydrated) return;
    nav({ to: setupDone ? (TAB_TO[lastTab] ?? "/months") : "/get-started", replace: true });
  }, [hydrated, setupDone, lastTab, nav]);
  return null;
}
