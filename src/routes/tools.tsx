import { Outlet, createFileRoute } from "@tanstack/react-router";
import { OverlayPage } from "../components/overlay-page";

export const Route = createFileRoute("/tools")({
  component: () => (
    <OverlayPage>
      <Outlet />
    </OverlayPage>
  ),
});
