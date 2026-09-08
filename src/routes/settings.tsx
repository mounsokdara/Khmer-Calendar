import { Outlet, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/settings")({
  component: () => (
    <section className="tab-page is-full overlay-page">
      <Outlet />
    </section>
  ),
});
