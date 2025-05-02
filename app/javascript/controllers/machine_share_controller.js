// app/javascript/controllers/machine_share_controller.js
import { Controller } from "@hotwired/stimulus";
import QRCodeStyling from "qr-code-styling"

export default class extends Controller {
  static targets = ["modal"]
  static values = { url: String }

  qrcode(event) {
    const modal = this.modalTarget

    if (modal.innerHTML == "") {
      const qr = new QRCodeStyling({
        width: 200,
        height: 200,
        data: `${this.urlValue}?r=qr`,
        dotsOptions: { color: "#000", type: "rounded" },
        backgroundOptions: { color: "#fff" }
      });

      qr.append(modal);
    }
  }

  copy(event) {
    navigator.clipboard.writeText(this.urlValue)
      .then(() => this.showToast())
      .catch(() => alert("コピーに失敗しました"));
  }

  showToast() {
    const toastEl = document.querySelector(".toast");
    if (toastEl) {
      const toast = new bootstrap.Toast(toastEl);
      toast.show();
    }
  }
}