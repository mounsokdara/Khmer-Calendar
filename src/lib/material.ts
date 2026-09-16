let loaded = false;

export async function loadMaterial() {
  if (loaded || typeof window === "undefined") return;
  loaded = true;
  await Promise.all([
    import("@material/web/ripple/ripple.js"),
    import("@material/web/focus/md-focus-ring.js"),
    import("@material/web/elevation/elevation.js"),
    import("@material/web/icon/icon.js"),
    import("@material/web/button/filled-button.js"),
    import("@material/web/button/outlined-button.js"),
    import("@material/web/button/text-button.js"),
    import("@material/web/button/filled-tonal-button.js"),
    import("@material/web/iconbutton/icon-button.js"),
    import("@material/web/iconbutton/outlined-icon-button.js"),
    import("@material/web/iconbutton/filled-icon-button.js"),
    import("@material/web/iconbutton/filled-tonal-icon-button.js"),
    import("@material/web/checkbox/checkbox.js"),
    import("@material/web/radio/radio.js"),
    import("@material/web/switch/switch.js"),
    import("@material/web/slider/slider.js"),
    import("@material/web/tabs/tabs.js"),
    import("@material/web/tabs/primary-tab.js"),
    import("@material/web/progress/circular-progress.js"),
    import("@material/web/progress/linear-progress.js"),
    import("@material/web/divider/divider.js"),
    import("@material/web/list/list.js"),
    import("@material/web/list/list-item.js"),
    import("@material/web/chips/chip-set.js"),
    import("@material/web/chips/assist-chip.js"),
    import("@material/web/chips/filter-chip.js"),
    import("@material/web/textfield/outlined-text-field.js"),
  ]);
}

export function materialReady() {
  return typeof customElements !== "undefined" && !!customElements.get("md-filled-button");
}
