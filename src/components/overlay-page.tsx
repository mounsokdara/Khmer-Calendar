import { useEffect, useState, type ReactNode } from "react";
import { createPortal } from "react-dom";

/** Full-screen layer that stacks over the tab bar, same as the reminder sheet. */
export function OverlayPage({ children, className = "tab-page is-full overlay-page" }: { children: ReactNode; className?: string }) {
  const [host, setHost] = useState<HTMLElement | null>(null);
  useEffect(() => setHost(document.body), []);
  const node = <section className={className}>{children}</section>;
  if (!host) return node;
  return createPortal(node, host);
}

export function CoverSheet({ children, className }: { children: ReactNode; className?: string }) {
  const [host, setHost] = useState<HTMLElement | null>(null);
  useEffect(() => setHost(document.body), []);
  const node = <div className={className}>{children}</div>;
  if (!host) return node;
  return createPortal(node, host);
}
