import{n as e,o as t,p as n,t as r,u as i}from"./lit-5_RjNOSR.js";import{t as a}from"./class-map-Bahm-H-9.js";import{t as o}from"./delegate-35YFFyzv.js";var s=o(r),c=class extends s{constructor(){super(...arguments),this.value=0,this.max=1,this.indeterminate=!1,this.fourColor=!1}render(){let{ariaLabel:n}=this;return t`
      <div
        class="progress ${a(this.getRenderClasses())}"
        role="progressbar"
        aria-label="${n||e}"
        aria-valuemin="0"
        aria-valuemax=${this.max}
        aria-valuenow=${this.indeterminate?e:this.value}
        >${this.renderIndicator()}</div
      >
    `}getRenderClasses(){return{indeterminate:this.indeterminate,"four-color":this.fourColor}}};n([i({type:Number})],c.prototype,`value`,void 0),n([i({type:Number})],c.prototype,`max`,void 0),n([i({type:Boolean})],c.prototype,`indeterminate`,void 0),n([i({type:Boolean,attribute:`four-color`})],c.prototype,`fourColor`,void 0);export{c as t};