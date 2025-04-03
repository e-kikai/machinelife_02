import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["machines", "output"]

  call(event) {
    let attr     = event.currentTarget.dataset.attr;
    let parent   = this.machinesTarget;
    let machines = Array.from(parent.children);

    machines.sort((a, b) => {
      let aValue = a.dataset[attr]?.trim();
      let bValue = b.dataset[attr]?.trim();

      // 空白のものは後ろに回す
      if (!aValue) return 1;
      if (!bValue) return -1;

      // 数値としてソート
      let aNum = parseFloat(aValue);
      let bNum = parseFloat(bValue);

      if (!isNaN(aNum) && !isNaN(bNum)) {
        if (aNum !== bNum) {
          if (attr == "year" || attr == "access" || attr == "news") {
            return bNum - aNum;
          } else {
            return aNum - bNum;
          }
        }
      } else {
        // 数値で比較できない場合は文字列として比較
        let result = aValue.localeCompare(bValue, undefined, { numeric: true });
        if (result !== 0) return result;
      }
    });

    machines.forEach(ma => parent.appendChild(ma)); // 並び替えた順に再配置
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
