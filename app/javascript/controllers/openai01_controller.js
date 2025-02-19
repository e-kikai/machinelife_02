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

    let targetElement = event.currentTarget;
    let input = this.textareaTarget;
    let re_message = targetElement.querySelector(".re_message");
    console.log(re_message);

    let content = '<i class="material-icons" aria-hidden="true">search</i> ';
    if (re_message) {
      content += re_message.value;
      content += '<br /><i class="material-icons" aria-hidden="true">filter_alt</i> ';

      let selects = targetElement.querySelectorAll("input[type=checkbox]:checked");

      selects.forEach((ckb) => {
        content += " " + ckb.value;
      });

    } else {
      content += input.value;
    }

    mes.removeAttribute("data-openai01-target");
    // mes.lastChild.textContent = input.value;
    mes.lastChild.innerHTML = content;
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
