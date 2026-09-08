import{i as e,n as t}from"./decorators-B_2ST9qI.js";import{n,o as r,t as i}from"./lit-CNvNe9Hv.js";import{t as a}from"./class-map-Bpf1FVQH.js";import{t as o}from"./delegate-sF5YSpZe.js";var s=o(i),c=class extends s{constructor(){super(...arguments),this.value=0,this.max=1,this.indeterminate=!1,this.fourColor=!1}render(){let{ariaLabel:e}=this;return r`
      <div
        class="progress ${a(this.getRenderClasses())}"
        role="progressbar"
        aria-label="${e||n}"
        aria-valuemin="0"
        aria-valuemax=${this.max}
        aria-valuenow=${this.indeterminate?n:this.value}
        >${this.renderIndicator()}</div
      >
    `}getRenderClasses(){return{indeterminate:this.indeterminate,"four-color":this.fourColor}}};e([t({type:Number})],c.prototype,`value`,void 0),e([t({type:Number})],c.prototype,`max`,void 0),e([t({type:Boolean})],c.prototype,`indeterminate`,void 0),e([t({type:Boolean,attribute:`four-color`})],c.prototype,`fourColor`,void 0);export{c as t};