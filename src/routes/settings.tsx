import { Outlet, createFileRoute } from "@tanstack/react-router";
import { OverlayPage } from "../components/overlay-page";

export const Route = createFileRoute("/settings")({
  component: () => (
    <OverlayPage>
      <Outlet />
    </OverlayPage>
  ),
});
