import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["img"]

  connect() {
    this.zoomed = false
    this.originX = "50%"
    this.originY = "50%"
  }

  toggle(event) {
    const img = event.target
    this.zoomed = !this.zoomed

    // マウス位置を取得して transform-origin に反映
    const rect = img.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width) * 100
    const y = ((event.clientY - rect.top) / rect.height) * 100
    this.originX = `${x}%`
    this.originY = `${y}%`

    if (this.zoomed) {
      img.style.transition = "transform 0.3s ease"
      img.style.transformOrigin = `${this.originX} ${this.originY}`
      img.style.transform = "scale(3)"
      img.style.cursor = "zoom-out"
    } else {
      img.style.transition = "transform 0.3s ease"
      img.style.transform = "scale(1)"
      img.style.cursor = "zoom-in"
    }
  }
}
