import{o as e,p as t,t as n,u as r}from"./lit-5_RjNOSR.js";import"./md-focus-ring-BLv9Mkpn.js";import{t as i}from"./class-map-Bahm-H-9.js";import"./ripple-zH2MfXZD.js";import{t as a}from"./delegate-35YFFyzv.js";var o=a(n),s=class extends o{get rippleDisabled(){return this.disabled||this.softDisabled}constructor(){super(),this.disabled=!1,this.softDisabled=!1,this.alwaysFocusable=!1,this.label=``,this.hasIcon=!1,this.addEventListener(`click`,this.handleClick.bind(this))}focus(e){(!this.disabled||this.alwaysFocusable)&&super.focus(e)}render(){return e`
      <div class="container ${i(this.getContainerClasses())}">
        ${this.renderContainerContent()}
      </div>
    `}updated(e){e.has(`disabled`)&&e.get(`disabled`)!==void 0&&this.dispatchEvent(new Event(`update-focus`,{bubbles:!0}))}getContainerClasses(){return{disabled:this.disabled||this.softDisabled,"has-icon":this.hasIcon}}renderContainerContent(){return e`
      ${this.renderOutline()}
      <md-focus-ring part="focus-ring" for=${this.primaryId}></md-focus-ring>
      <md-ripple
        for=${this.primaryId}
        ?disabled=${this.rippleDisabled}></md-ripple>
      ${this.renderPrimaryAction(this.renderPrimaryContent())}
    `}renderOutline(){return e`<span class="outline"></span>`}renderLeadingIcon(){return e`<slot name="icon" @slotchange=${this.handleIconChange}></slot>`}renderPrimaryContent(){return e`
      <span class="leading icon" aria-hidden="true">
        ${this.renderLeadingIcon()}
      </span>
      <span class="label">
        <span class="label-text" id="label">
          ${this.label?this.label:e`<slot></slot>`}
        </span>
      </span>
      <span class="touch"></span>
    `}handleIconChange(e){let t=e.target;this.hasIcon=t.assignedElements({flatten:!0}).length>0}handleClick(e){if(this.softDisabled||this.disabled&&this.alwaysFocusable){e.stopImmediatePropagation(),e.preventDefault();return}}};s.shadowRootOptions={...n.shadowRootOptions,delegatesFocus:!0},t([r({type:Boolean,reflect:!0})],s.prototype,`disabled`,void 0),t([r({type:Boolean,attribute:`soft-disabled`,reflect:!0})],s.prototype,`softDisabled`,void 0),t([r({type:Boolean,attribute:`always-focusable`})],s.prototype,`alwaysFocusable`,void 0),t([r()],s.prototype,`label`,void 0),t([r({type:Boolean,reflect:!0,attribute:`has-icon`})],s.prototype,`hasIcon`,void 0);export{s as t};