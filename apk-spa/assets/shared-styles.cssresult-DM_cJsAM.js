import{d as e,l as t,n,o as r,p as i,t as a,u as o}from"./lit-5_RjNOSR.js";import"./md-focus-ring-BLv9Mkpn.js";import{t as s}from"./class-map-Bahm-H-9.js";import"./ripple-zH2MfXZD.js";import{t as c}from"./delegate-35YFFyzv.js";import{a as l,r as u}from"./form-associated-84zRtddo.js";import{n as d,t as f}from"./dispatch-hooks-DMohpSO2.js";import{t as p}from"./form-submitter-DPXP5kgd.js";import{n as m,t as h}from"./static-html-Ep2YlAxw.js";function g(e,t=!0){return t&&getComputedStyle(e).getPropertyValue(`direction`).trim()===`rtl`}var _=c(p(u(l(a)))),v=class extends _{constructor(){super(),this.softDisabled=!1,this.flipIconInRtl=!1,this.href=``,this.download=``,this.target=``,this.ariaLabelSelected=``,this.toggle=!1,this.selected=!1,this.flipIcon=g(this,this.flipIconInRtl),d(this,`click`),this.addEventListener(`click`,e=>{if(this.softDisabled||this.disabled&&this.href){e.stopImmediatePropagation(),e.preventDefault();return}let t=this.selected;f(e,()=>{!this.toggle||this.disabled||e.defaultPrevented||(this.selected=!t,this.dispatchEvent(new InputEvent(`input`,{bubbles:!0,composed:!0})),this.dispatchEvent(new Event(`change`,{bubbles:!0})))})})}willUpdate(){this.href&&(this.disabled=!1,this.softDisabled=!1)}render(){let e=this.href?h`div`:h`button`,{ariaLabel:t,ariaHasPopup:r,ariaExpanded:i}=this,a=t&&this.ariaLabelSelected,o=this.toggle?this.selected:n,c=n;return this.href||(c=a&&this.selected?this.ariaLabelSelected:t),m`<${e}
        class="icon-button ${s(this.getRenderClasses())}"
        id="button"
        aria-label="${c||n}"
        aria-haspopup="${!this.href&&r||n}"
        aria-expanded="${!this.href&&i||n}"
        aria-pressed="${o}"
        aria-disabled=${!this.href&&this.softDisabled||n}
        ?disabled="${!this.href&&this.disabled}">
        ${this.renderFocusRing()}
        ${this.renderRipple()}
        ${this.selected?n:this.renderIcon()}
        ${this.selected?this.renderSelectedIcon():n}
        ${this.href?this.renderLink():this.renderTouchTarget()}
  </${e}>`}renderLink(){let{ariaLabel:e}=this;return r`
      <a
        class="link"
        id="link"
        href="${this.href}"
        download="${this.download||n}"
        target="${this.target||n}"
        aria-label="${e||n}">
        ${this.renderTouchTarget()}
      </a>
    `}getRenderClasses(){return{"flip-icon":this.flipIcon,selected:this.toggle&&this.selected}}renderIcon(){return r`<span class="icon"><slot></slot></span>`}renderSelectedIcon(){return r`<span class="icon icon--selected"
      ><slot name="selected"><slot></slot></slot
    ></span>`}renderTouchTarget(){return r`<span class="touch"></span>`}renderFocusRing(){return r`<md-focus-ring
      part="focus-ring"
      for=${this.href?`link`:`button`}></md-focus-ring>`}renderRipple(){let e=!this.href&&(this.disabled||this.softDisabled);return r`<md-ripple
      for=${this.href?`link`:n}
      ?disabled="${e}"></md-ripple>`}connectedCallback(){this.flipIcon=g(this,this.flipIconInRtl),super.connectedCallback()}};v.shadowRootOptions={mode:`open`,delegatesFocus:!0},i([o({type:Boolean,attribute:`soft-disabled`,reflect:!0})],v.prototype,`softDisabled`,void 0),i([o({type:Boolean,attribute:`flip-icon-in-rtl`})],v.prototype,`flipIconInRtl`,void 0),i([o()],v.prototype,`href`,void 0),i([o()],v.prototype,`download`,void 0),i([o()],v.prototype,`target`,void 0),i([o({attribute:`aria-label-selected`})],v.prototype,`ariaLabelSelected`,void 0),i([o({type:Boolean})],v.prototype,`toggle`,void 0),i([o({type:Boolean,reflect:!0})],v.prototype,`selected`,void 0),i([t()],v.prototype,`flipIcon`,void 0);var y=e`:host{display:inline-flex;outline:none;-webkit-tap-highlight-color:rgba(0,0,0,0);height:var(--_container-height);width:var(--_container-width);justify-content:center}:host([touch-target=wrapper]){margin:max(0px,(48px - var(--_container-height))/2) max(0px,(48px - var(--_container-width))/2)}md-focus-ring{--md-focus-ring-shape-start-start: var(--_container-shape-start-start);--md-focus-ring-shape-start-end: var(--_container-shape-start-end);--md-focus-ring-shape-end-end: var(--_container-shape-end-end);--md-focus-ring-shape-end-start: var(--_container-shape-end-start)}:host(:is([disabled],[soft-disabled])){pointer-events:none}.icon-button{place-items:center;background:none;border:none;box-sizing:border-box;cursor:pointer;display:flex;place-content:center;outline:none;padding:0;position:relative;text-decoration:none;user-select:none;z-index:0;flex:1;border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end)}.icon ::slotted(*){font-size:var(--_icon-size);height:var(--_icon-size);width:var(--_icon-size);font-weight:inherit}md-ripple{z-index:-1;border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end)}.flip-icon .icon{transform:scaleX(-1)}.icon{display:inline-flex}.link{display:grid;height:100%;outline:none;place-items:center;position:absolute;width:100%}.touch{position:absolute;height:max(48px,100%);width:max(48px,100%)}:host([touch-target=none]) .touch{display:none}@media(forced-colors: active){:host(:is([disabled],[soft-disabled])){--_disabled-icon-color: GrayText;--_disabled-icon-opacity: 1}}
`;y.styleSheet;export{v as n,y as t};