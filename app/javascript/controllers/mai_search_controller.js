import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textarea", "output", "loading", "button"]

  connect() {
    if (this.textareaTarget.value) {
      this.buttonTarget.click();
    }
  }

  sendMessage() {
    // message
    let temp    = this.loadingTarget.content;
    let mes     = temp.children[1].cloneNode(true);
    let loading = temp.children[0].cloneNode(true);

    let targetElement = event.currentTarget;
    let input = this.textareaTarget;
    let re_message = targetElement.querySelector(".re_message");

    let content = '<i class="material-icons" aria-hidden="true">search</i> ';

    // フィルタリング
    if (re_message) {
      content += re_message.value;
      content += '<br /><i class="material-icons" aria-hidden="true">filter_alt</i> ';

      let selects = targetElement.querySelectorAll("input[type=checkbox]:checked");
      selects.forEach((ckb) => {
        content += " " + ckb.value;
      });
    } else {
      // フォームから
      content += input.value;
    }

    mes.lastChild.innerHTML = content;
    this.outputTarget.prepend(mes);

    input.readOnly = true;

    // loading
    loading.setAttribute("id", "result_area");

    this.outputTarget.prepend(loading);
  }
}
