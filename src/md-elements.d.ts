import type { DOMAttributes, Ref } from "react";

type MdEl = HTMLElement & {
  activeTabIndex?: number;
  checked?: boolean;
  selected?: boolean;
  indeterminate?: boolean;
  value?: number | string;
  attach?: (host: EventTarget) => void;
  unbounded?: boolean;
};

type MdProps = DOMAttributes<HTMLElement> & {
  class?: string;
  className?: string;
  checked?: boolean;
  selected?: boolean;
  disabled?: boolean;
  indeterminate?: boolean;
  labeled?: boolean;
  unbounded?: boolean;
  name?: string;
  value?: string | number;
  min?: number;
  max?: number;
  step?: number;
  active?: boolean;
  activeTabIndex?: number;
  ref?: Ref<MdEl>;
  slot?: string;
  type?: string;
  "has-icon"?: boolean;
  "touch-target"?: string;
  "aria-label"?: string;
  "aria-describedby"?: string;
};

declare module "react" {
  namespace JSX {
    interface IntrinsicElements {
      "md-ripple": MdProps;
      "md-focus-ring": MdProps;
      "md-elevation": MdProps;
      "md-checkbox": MdProps;
      "md-radio": MdProps;
      "md-switch": MdProps;
      "md-slider": MdProps;
      "md-filled-button": MdProps;
      "md-outlined-button": MdProps;
      "md-text-button": MdProps;
      "md-filled-tonal-button": MdProps;
      "md-icon-button": MdProps;
      "md-outlined-icon-button": MdProps;
      "md-filled-icon-button": MdProps;
      "md-filled-tonal-icon-button": MdProps;
      "md-tabs": MdProps;
      "md-primary-tab": MdProps;
      "md-circular-progress": MdProps;
      "md-linear-progress": MdProps;
      "md-fab": MdProps;
      "md-icon": MdProps;
      "md-divider": MdProps;
      "md-list": MdProps;
      "md-list-item": MdProps;
      "md-chip-set": MdProps;
      "md-assist-chip": MdProps;
      "md-filter-chip": MdProps;
      "md-outlined-text-field": MdProps;
    }
  }
}

export {};
