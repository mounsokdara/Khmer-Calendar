import { Outlet, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/settings")({
  component: () => (
    <section className="tab-page overlay-page">
      <Outlet />
    </section>
  ),
});
