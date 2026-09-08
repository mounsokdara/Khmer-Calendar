import{i as e,n as t,t as n}from"./decorators-B_2ST9qI.js";import{d as r,n as i,o as a,t as o}from"./lit-CNvNe9Hv.js";import"./md-focus-ring-CnNW8goZ.js";import{t as s}from"./class-map-Bpf1FVQH.js";import"./ripple-D_dK8xjW.js";import{t as c}from"./delegate-sF5YSpZe.js";import{a as l,r as u}from"./form-associated-CuE0hpUj.js";import{n as d,t as f}from"./dispatch-hooks-DMohpSO2.js";import{t as p}from"./form-submitter-vpObi5xH.js";import{n as m,t as h}from"./static-html-D5Ouu-bP.js";import{t as g}from"./is-rtl-BWiJIbvO.js";var _=c(p(u(l(o)))),v=class extends _{constructor(){super(),this.softDisabled=!1,this.flipIconInRtl=!1,this.href=``,this.download=``,this.target=``,this.ariaLabelSelected=``,this.toggle=!1,this.selected=!1,this.flipIcon=g(this,this.flipIconInRtl),d(this,`click`),this.addEventListener(`click`,e=>{if(this.softDisabled||this.disabled&&this.href){e.stopImmediatePropagation(),e.preventDefault();return}let t=this.selected;f(e,()=>{!this.toggle||this.disabled||e.defaultPrevented||(this.selected=!t,this.dispatchEvent(new InputEvent(`input`,{bubbles:!0,composed:!0})),this.dispatchEvent(new Event(`change`,{bubbles:!0})))})})}willUpdate(){this.href&&(this.disabled=!1,this.softDisabled=!1)}render(){let e=this.href?h`div`:h`button`,{ariaLabel:t,ariaHasPopup:n,ariaExpanded:r}=this,a=t&&this.ariaLabelSelected,o=this.toggle?this.selected:i,c=i;return this.href||(c=a&&this.selected?this.ariaLabelSelected:t),m`<${e}
        class="icon-button ${s(this.getRenderClasses())}"
        id="button"
        aria-label="${c||i}"
        aria-haspopup="${!this.href&&n||i}"
        aria-expanded="${!this.href&&r||i}"
        aria-pressed="${o}"
        aria-disabled=${!this.href&&this.softDisabled||i}
        ?disabled="${!this.href&&this.disabled}">
        ${this.renderFocusRing()}
        ${this.renderRipple()}
        ${this.selected?i:this.renderIcon()}
        ${this.selected?this.renderSelectedIcon():i}
        ${this.href?this.renderLink():this.renderTouchTarget()}
  </${e}>`}renderLink(){let{ariaLabel:e}=this;return a`
      <a
        class="link"
        id="link"
        href="${this.href}"
        download="${this.download||i}"
        target="${this.target||i}"
        aria-label="${e||i}">
        ${this.renderTouchTarget()}
      </a>
    `}getRenderClasses(){return{"flip-icon":this.flipIcon,selected:this.toggle&&this.selected}}renderIcon(){return a`<span class="icon"><slot></slot></span>`}renderSelectedIcon(){return a`<span class="icon icon--selected"
      ><slot name="selected"><slot></slot></slot
    ></span>`}renderTouchTarget(){return a`<span class="touch"></span>`}renderFocusRing(){return a`<md-focus-ring
      part="focus-ring"
      for=${this.href?`link`:`button`}></md-focus-ring>`}renderRipple(){let e=!this.href&&(this.disabled||this.softDisabled);return a`<md-ripple
      for=${this.href?`link`:i}
      ?disabled="${e}"></md-ripple>`}connectedCallback(){this.flipIcon=g(this,this.flipIconInRtl),super.connectedCallback()}};v.shadowRootOptions={mode:`open`,delegatesFocus:!0},e([t({type:Boolean,attribute:`soft-disabled`,reflect:!0})],v.prototype,`softDisabled`,void 0),e([t({type:Boolean,attribute:`flip-icon-in-rtl`})],v.prototype,`flipIconInRtl`,void 0),e([t()],v.prototype,`href`,void 0),e([t()],v.prototype,`download`,void 0),e([t()],v.prototype,`target`,void 0),e([t({attribute:`aria-label-selected`})],v.prototype,`ariaLabelSelected`,void 0),e([t({type:Boolean})],v.prototype,`toggle`,void 0),e([t({type:Boolean,reflect:!0})],v.prototype,`selected`,void 0),e([n()],v.prototype,`flipIcon`,void 0);var y=r`:host{display:inline-flex;outline:none;-webkit-tap-highlight-color:rgba(0,0,0,0);height:var(--_container-height);width:var(--_container-width);justify-content:center}:host([touch-target=wrapper]){margin:max(0px,(48px - var(--_container-height))/2) max(0px,(48px - var(--_container-width))/2)}md-focus-ring{--md-focus-ring-shape-start-start: var(--_container-shape-start-start);--md-focus-ring-shape-start-end: var(--_container-shape-start-end);--md-focus-ring-shape-end-end: var(--_container-shape-end-end);--md-focus-ring-shape-end-start: var(--_container-shape-end-start)}:host(:is([disabled],[soft-disabled])){pointer-events:none}.icon-button{place-items:center;background:none;border:none;box-sizing:border-box;cursor:pointer;display:flex;place-content:center;outline:none;padding:0;position:relative;text-decoration:none;user-select:none;z-index:0;flex:1;border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end)}.icon ::slotted(*){font-size:var(--_icon-size);height:var(--_icon-size);width:var(--_icon-size);font-weight:inherit}md-ripple{z-index:-1;border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end)}.flip-icon .icon{transform:scaleX(-1)}.icon{display:inline-flex}.link{display:grid;height:100%;outline:none;place-items:center;position:absolute;width:100%}.touch{position:absolute;height:max(48px,100%);width:max(48px,100%)}:host([touch-target=none]) .touch{display:none}@media(forced-colors: active){:host(:is([disabled],[soft-disabled])){--_disabled-icon-color: GrayText;--_disabled-icon-opacity: 1}}
`;y.styleSheet;export{v as n,y as t};