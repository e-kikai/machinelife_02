import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textarea", "output", "dummy", "loading"]

  sendMessage() {
    let mes = this.dummyTarget.cloneNode(true);
    let input = this.textareaTarget;
    mes.removeAttribute("data-openai01-target");
    mes.lastChild.textContent = input.value;
    mes.classList.remove('d-none');

    this.outputTarget.prepend(mes);
    input.readOnly = true;


    let loading = this.loadingTarget.cloneNode(true);
    loading.removeAttribute("data-openai01-target");
    loading.classList.remove('d-none');
    loading.setAttribute("id", "result_area");

    console.log(loading);

    this.outputTarget.prepend(loading);
  }
}
