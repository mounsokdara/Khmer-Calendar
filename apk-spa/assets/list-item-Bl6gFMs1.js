import{i as e,n as t,r as n}from"./decorators-B_2ST9qI.js";import{d as r,n as i,o as a,t as o}from"./lit-CNvNe9Hv.js";import{r as s}from"./animation-B6BR39kN.js";import"./item-Cecio28_.js";import"./md-focus-ring-CnNW8goZ.js";import{t as c}from"./class-map-Bpf1FVQH.js";import"./ripple-D_dK8xjW.js";import{t as l}from"./delegate-sF5YSpZe.js";import{n as u,t as d}from"./static-html-D5Ouu-bP.js";import{a as f}from"./list-navigation-helpers-YOBkfJ0H.js";var p=l(o),m=class extends p{constructor(){super(...arguments),this.disabled=!1,this.type=`text`,this.isListItem=!0,this.href=``,this.target=``}get isDisabled(){return this.disabled&&this.type!==`link`}willUpdate(e){this.href&&(this.type=`link`),super.willUpdate(e)}render(){return this.renderListItem(a`
      <md-item>
        <div slot="container">
          ${this.renderRipple()} ${this.renderFocusRing()}
        </div>
        <slot name="start" slot="start"></slot>
        <slot name="end" slot="end"></slot>
        ${this.renderBody()}
      </md-item>
    `)}renderListItem(e){let t=this.type===`link`,n;switch(this.type){case`link`:n=d`a`;break;case`button`:n=d`button`;break;default:case`text`:n=d`li`}let r=this.type!==`text`,a=t&&this.target?this.target:i;return u`
      <${n}
        id="item"
        tabindex="${this.isDisabled||!r?-1:0}"
        ?disabled=${this.isDisabled}
        role="listitem"
        aria-selected=${this.ariaSelected||i}
        aria-checked=${this.ariaChecked||i}
        aria-expanded=${this.ariaExpanded||i}
        aria-haspopup=${this.ariaHasPopup||i}
        class="list-item ${c(this.getRenderClasses())}"
        href=${this.href||i}
        target=${a}
        @focus=${this.onFocus}
      >${e}</${n}>
    `}renderRipple(){return this.type===`text`?i:a` <md-ripple
      part="ripple"
      for="item"
      ?disabled=${this.isDisabled}></md-ripple>`}renderFocusRing(){return this.type===`text`?i:a` <md-focus-ring
      @visibility-changed=${this.onFocusRingVisibilityChanged}
      part="focus-ring"
      for="item"
      inward></md-focus-ring>`}onFocusRingVisibilityChanged(e){}getRenderClasses(){return{disabled:this.isDisabled}}renderBody(){return a`
      <slot></slot>
      <slot name="overline" slot="overline"></slot>
      <slot name="headline" slot="headline"></slot>
      <slot name="supporting-text" slot="supporting-text"></slot>
      <slot
        name="trailing-supporting-text"
        slot="trailing-supporting-text"></slot>
    `}onFocus(){this.tabIndex===-1&&this.dispatchEvent(f())}focus(){this.listItemRoot?.focus()}click(){if(!this.listItemRoot){super.click();return}this.listItemRoot.click()}};m.shadowRootOptions={...o.shadowRootOptions,delegatesFocus:!0},e([t({type:Boolean,reflect:!0})],m.prototype,`disabled`,void 0),e([t({reflect:!0})],m.prototype,`type`,void 0),e([t({type:Boolean,attribute:`md-list-item`,reflect:!0})],m.prototype,`isListItem`,void 0),e([t()],m.prototype,`href`,void 0),e([t()],m.prototype,`target`,void 0),e([s(`.list-item`)],m.prototype,`listItemRoot`,void 0);var h=r`:host{display:flex;gap:16px;-webkit-tap-highlight-color:rgba(0,0,0,0);--md-ripple-hover-color: var(--md-list-item-hover-state-layer-color, var(--md-sys-color-on-surface, #1d1b20));--md-ripple-hover-opacity: var(--md-list-item-hover-state-layer-opacity, 0.08);--md-ripple-pressed-color: var(--md-list-item-pressed-state-layer-color, var(--md-sys-color-on-surface, #1d1b20));--md-ripple-pressed-opacity: var(--md-list-item-pressed-state-layer-opacity, 0.12)}:host(:is([type=button]:not([disabled]),[type=link])){cursor:pointer}md-focus-ring{z-index:1;--md-focus-ring-shape: 8px}a,button,li{background:none;border:none;cursor:inherit;padding:0;margin:0;text-align:unset;text-decoration:none}.list-item{border-radius:inherit;display:flex;flex:1;gap:inherit;max-width:inherit;min-width:inherit;outline:none;-webkit-tap-highlight-color:rgba(0,0,0,0);width:100%}.list-item.interactive{cursor:pointer}.list-item.disabled{opacity:var(--md-list-item-disabled-opacity, 0.3);pointer-events:none}[slot=container]{pointer-events:none}md-ripple{border-radius:inherit}md-item{border-radius:inherit;flex:1;height:100%;color:var(--md-list-item-label-text-color, var(--md-sys-color-on-surface, #1d1b20));font-family:var(--md-list-item-label-text-font, var(--md-sys-typescale-body-large-font, var(--md-ref-typeface-plain, Roboto)));font-size:var(--md-list-item-label-text-size, var(--md-sys-typescale-body-large-size, 1rem));line-height:var(--md-list-item-label-text-line-height, var(--md-sys-typescale-body-large-line-height, 1.5rem));font-weight:var(--md-list-item-label-text-weight, var(--md-sys-typescale-body-large-weight, var(--md-ref-typeface-weight-regular, 400)));min-height:var(--md-list-item-one-line-container-height, 56px);padding-top:var(--md-list-item-top-space, 12px);padding-bottom:var(--md-list-item-bottom-space, 12px);padding-inline-start:var(--md-list-item-leading-space, 16px);padding-inline-end:var(--md-list-item-trailing-space, 16px);gap:inherit}md-item[multiline]{min-height:var(--md-list-item-two-line-container-height, 72px)}[slot=supporting-text]{color:var(--md-list-item-supporting-text-color, var(--md-sys-color-on-surface-variant, #49454f));font-family:var(--md-list-item-supporting-text-font, var(--md-sys-typescale-body-medium-font, var(--md-ref-typeface-plain, Roboto)));font-size:var(--md-list-item-supporting-text-size, var(--md-sys-typescale-body-medium-size, 0.875rem));line-height:var(--md-list-item-supporting-text-line-height, var(--md-sys-typescale-body-medium-line-height, 1.25rem));font-weight:var(--md-list-item-supporting-text-weight, var(--md-sys-typescale-body-medium-weight, var(--md-ref-typeface-weight-regular, 400)))}[slot=trailing-supporting-text]{color:var(--md-list-item-trailing-supporting-text-color, var(--md-sys-color-on-surface-variant, #49454f));font-family:var(--md-list-item-trailing-supporting-text-font, var(--md-sys-typescale-label-small-font, var(--md-ref-typeface-plain, Roboto)));font-size:var(--md-list-item-trailing-supporting-text-size, var(--md-sys-typescale-label-small-size, 0.6875rem));line-height:var(--md-list-item-trailing-supporting-text-line-height, var(--md-sys-typescale-label-small-line-height, 1rem));font-weight:var(--md-list-item-trailing-supporting-text-weight, var(--md-sys-typescale-label-small-weight, var(--md-ref-typeface-weight-medium, 500)))}:is([slot=start],[slot=end])::slotted(*){fill:currentColor}[slot=start]{color:var(--md-list-item-leading-icon-color, var(--md-sys-color-on-surface-variant, #49454f))}[slot=end]{color:var(--md-list-item-trailing-icon-color, var(--md-sys-color-on-surface-variant, #49454f))}@media(forced-colors: active){.disabled slot{color:GrayText}.list-item.disabled{color:GrayText;opacity:1}}
`;h.styleSheet;var g=class extends m{};g.styles=[h],g=e([n(`md-list-item`)],g);export{g as MdListItem};