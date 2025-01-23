import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textarea", "output", "dummy", "loading", "button"]

  connect() {
    if (this.textareaTarget.value) {
      this.buttonTarget.click();
    }
  }

  sendMessage() {
    // message
    let mes = this.dummyTarget.cloneNode(true);
    let input = this.textareaTarget;
    mes.removeAttribute("data-openai01-target");
    mes.lastChild.textContent = input.value;
    mes.classList.remove('d-none');

    this.outputTarget.prepend(mes);
    input.readOnly = true;

    // loading
    let loading = this.loadingTarget.cloneNode(true);
    loading.removeAttribute("data-openai01-target");
    loading.classList.remove('d-none');
    loading.setAttribute("id", "result_area");

    this.outputTarget.prepend(loading);
  }
}
