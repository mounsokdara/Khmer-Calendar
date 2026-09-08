import{d as e,n as t,o as n,p as r,t as i,u as a}from"./lit-5_RjNOSR.js";import{n as o}from"./animation-BLa2VixR.js";import{t as s}from"./query-assigned-elements-BBHe1xEY.js";import"./md-focus-ring-BLv9Mkpn.js";import"./ripple-zH2MfXZD.js";import{t as c}from"./delegate-35YFFyzv.js";import{n as l,t as u}from"./form-label-activation-B5g2G8SN.js";import{a as d,r as f}from"./form-associated-84zRtddo.js";import{t as p}from"./form-submitter-DPXP5kgd.js";var m=c(p(f(d(i)))),h=class extends m{constructor(){super(),this.softDisabled=!1,this.href=``,this.download=``,this.target=``,this.trailingIcon=!1,this.hasIcon=!1,this.addEventListener(`click`,this.handleClick.bind(this))}focus(){this.buttonElement?.focus()}blur(){this.buttonElement?.blur()}render(){let e=this.disabled||this.softDisabled,t=this.href?this.renderLink():this.renderButton(),r=this.href?`link`:`button`;return n`
      ${this.renderElevationOrOutline?.()}
      <div class="background"></div>
      <md-focus-ring part="focus-ring" for=${r}></md-focus-ring>
      <md-ripple
        part="ripple"
        for=${r}
        ?disabled="${e}"></md-ripple>
      ${t}
    `}renderButton(){let{ariaLabel:e,ariaHasPopup:r,ariaExpanded:i}=this;return n`<button
      id="button"
      class="button"
      ?disabled=${this.disabled}
      aria-disabled=${this.softDisabled||t}
      aria-label="${e||t}"
      aria-haspopup="${r||t}"
      aria-expanded="${i||t}">
      ${this.renderContent()}
    </button>`}renderLink(){let{ariaLabel:e,ariaHasPopup:r,ariaExpanded:i}=this;return n`<a
      id="link"
      class="button"
      aria-label="${e||t}"
      aria-haspopup="${r||t}"
      aria-expanded="${i||t}"
      aria-disabled=${this.disabled||this.softDisabled||t}
      tabindex="${this.disabled&&!this.softDisabled?-1:t}"
      href=${this.href}
      download=${this.download||t}
      target=${this.target||t}
      >${this.renderContent()}
    </a>`}renderContent(){let e=n`<slot
      name="icon"
      @slotchange="${this.handleSlotChange}"></slot>`;return n`
      <span class="touch"></span>
      ${this.trailingIcon?t:e}
      <span class="label"><slot></slot></span>
      ${this.trailingIcon?e:t}
    `}handleClick(e){if(this.softDisabled||this.disabled&&this.href){e.stopImmediatePropagation(),e.preventDefault();return}l(e)&&this.buttonElement&&(this.focus(),u(this.buttonElement))}handleSlotChange(){this.hasIcon=this.assignedIcons.length>0}};h.shadowRootOptions={mode:`open`,delegatesFocus:!0},r([a({type:Boolean,attribute:`soft-disabled`,reflect:!0})],h.prototype,`softDisabled`,void 0),r([a()],h.prototype,`href`,void 0),r([a()],h.prototype,`download`,void 0),r([a()],h.prototype,`target`,void 0),r([a({type:Boolean,attribute:`trailing-icon`,reflect:!0})],h.prototype,`trailingIcon`,void 0),r([a({type:Boolean,attribute:`has-icon`,reflect:!0})],h.prototype,`hasIcon`,void 0),r([o(`.button`)],h.prototype,`buttonElement`,void 0),r([s({slot:`icon`,flatten:!0})],h.prototype,`assignedIcons`,void 0);var g=e`:host{border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end);box-sizing:border-box;cursor:pointer;display:inline-flex;gap:8px;min-height:var(--_container-height);outline:none;padding-block:calc((var(--_container-height) - max(var(--_label-text-line-height),var(--_icon-size)))/2);padding-inline-start:var(--_leading-space);padding-inline-end:var(--_trailing-space);place-content:center;place-items:center;position:relative;font-family:var(--_label-text-font);font-size:var(--_label-text-size);line-height:var(--_label-text-line-height);font-weight:var(--_label-text-weight);text-overflow:ellipsis;text-wrap:nowrap;user-select:none;-webkit-tap-highlight-color:rgba(0,0,0,0);vertical-align:top;--md-ripple-hover-color: var(--_hover-state-layer-color);--md-ripple-pressed-color: var(--_pressed-state-layer-color);--md-ripple-hover-opacity: var(--_hover-state-layer-opacity);--md-ripple-pressed-opacity: var(--_pressed-state-layer-opacity)}md-focus-ring{--md-focus-ring-shape-start-start: var(--_container-shape-start-start);--md-focus-ring-shape-start-end: var(--_container-shape-start-end);--md-focus-ring-shape-end-end: var(--_container-shape-end-end);--md-focus-ring-shape-end-start: var(--_container-shape-end-start)}:host(:is([disabled],[soft-disabled])){cursor:default;pointer-events:none}.button{border-radius:inherit;cursor:inherit;display:inline-flex;align-items:center;justify-content:center;border:none;outline:none;-webkit-appearance:none;vertical-align:middle;background:rgba(0,0,0,0);text-decoration:none;min-width:calc(64px - var(--_leading-space) - var(--_trailing-space));width:100%;z-index:0;height:100%;font:inherit;color:var(--_label-text-color);padding:0;gap:inherit;text-transform:inherit}.button::-moz-focus-inner{padding:0;border:0}:host(:hover) .button{color:var(--_hover-label-text-color)}:host(:focus-within) .button{color:var(--_focus-label-text-color)}:host(:active) .button{color:var(--_pressed-label-text-color)}.background{background:var(--_container-color);border-radius:inherit;inset:0;position:absolute}.label{overflow:hidden}:is(.button,.label,.label slot),.label ::slotted(*){text-overflow:inherit}:host(:is([disabled],[soft-disabled])) .label{color:var(--_disabled-label-text-color);opacity:var(--_disabled-label-text-opacity)}:host(:is([disabled],[soft-disabled])) .background{background:var(--_disabled-container-color);opacity:var(--_disabled-container-opacity)}@media(forced-colors: active){.background{border:1px solid CanvasText}:host(:is([disabled],[soft-disabled])){--_disabled-icon-color: GrayText;--_disabled-icon-opacity: 1;--_disabled-container-opacity: 1;--_disabled-label-text-color: GrayText;--_disabled-label-text-opacity: 1}}:host([has-icon]:not([trailing-icon])){padding-inline-start:var(--_with-leading-icon-leading-space);padding-inline-end:var(--_with-leading-icon-trailing-space)}:host([has-icon][trailing-icon]){padding-inline-start:var(--_with-trailing-icon-leading-space);padding-inline-end:var(--_with-trailing-icon-trailing-space)}::slotted([slot=icon]){display:inline-flex;position:relative;writing-mode:horizontal-tb;fill:currentColor;flex-shrink:0;color:var(--_icon-color);font-size:var(--_icon-size);inline-size:var(--_icon-size);block-size:var(--_icon-size)}:host(:hover) ::slotted([slot=icon]){color:var(--_hover-icon-color)}:host(:focus-within) ::slotted([slot=icon]){color:var(--_focus-icon-color)}:host(:active) ::slotted([slot=icon]){color:var(--_pressed-icon-color)}:host(:is([disabled],[soft-disabled])) ::slotted([slot=icon]){color:var(--_disabled-icon-color);opacity:var(--_disabled-icon-opacity)}.touch{position:absolute;top:50%;height:max(48px,100%);left:0;right:0;transform:translateY(-50%)}:host([touch-target=wrapper]){margin:max(0px,(48px - var(--_container-height))/2) 0}:host([touch-target=none]) .touch{display:none}
`;g.styleSheet;export{h as n,g as t};