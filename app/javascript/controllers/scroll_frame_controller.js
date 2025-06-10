import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.toggle = this.toggle.bind(this)
    window.addEventListener("scroll", this.toggle)
    this.toggle() // 初期状態の判定
  }

  disconnect() {
    window.removeEventListener("scroll", this.toggle)
  }

  toggle() {
    const show = window.scrollY > 200
    this.buttonTarget.classList.toggle("d-none", !show)
  }

  scroll() {
    event.preventDefault();
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
}
