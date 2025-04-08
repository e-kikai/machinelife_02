import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textarea", "output", "loading", "button"]

  connect() {
    if (this.textareaTarget.value) {
      this.buttonTarget.click();
    }
  }

  sendMessage(event) {
    // message
    let temp    = this.loadingTarget.content;
    let mes     = temp.children[1].cloneNode(true);
    let loading = temp.children[0].cloneNode(true);

    let targetElement = event.currentTarget;
    let input = this.textareaTarget;
    let re_message = targetElement.querySelector(".re_message");

    // フィルタリング
    if (re_message) {
      mes.querySelector(".kwd").innerHTML = re_message.value;

      let content = "";
      let selects = targetElement.querySelectorAll("input[type=checkbox]:checked");
      selects.forEach((ckb) => {
        content += " " + ckb.value;
      });
      mes.querySelector(".fil").innerHTML = content;
      mes.querySelector(".filtering_area").style.display = "block";
    } else {
      mes.querySelector(".kwd").innerHTML = input.value;
      mes.querySelector(".filtering_area").style.display = "none";
    }

    this.outputTarget.prepend(mes);

    input.readOnly = true;

    // loading
    loading.setAttribute("id", "result_area");

    this.outputTarget.prepend(loading);
  }
}
