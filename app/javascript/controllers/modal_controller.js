import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "dialog", "modalBody", "spinner", "externalLink", "title", "detailLink"]

  connect() {
    this.modal = new bootstrap.Modal(this.modalTarget)
  }

  reset(dialogSize = null) {
    this.spinnerTarget.classList.remove("d-none")
    this.modalBodyTarget.innerHTML = ""
    this.externalLinkTarget.classList.add("d-none")
    this.detailLinkTarget.classList.add("d-none")
    this.titleTarget.textContent = ""

    this.dialogTarget.classList.remove("modal-sm", "modal-lg", "modal-xl")
    if (dialogSize) this.dialogTarget.classList.add(dialogSize)
  }

  finishLoading() {
    this.spinnerTarget.classList.add("d-none")
  }

  isMobile() {
    // iPhone, iPad, Androidスマホ・タブレット両方に対応
    return /iPhone|iPad|Android.+Mobile|Android(?!.*Mobile)/i.test(navigator.userAgent)
  }

  escapeHtml(unsafe) {
    return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  showModalContent(event, contentHtml, dialogSize) {
    const url = event.currentTarget.href
    const rawTitle = event.currentTarget.dataset.title || ""
    const title = this.escapeHtml(rawTitle)
    const id = event.currentTarget.dataset.id

    if (this.isMobile()) {
      window.open(url, "_blank")
      return
    }

    event.preventDefault()
    this.reset(dialogSize)

    this.modalBodyTarget.innerHTML = contentHtml
    this.externalLinkTarget.href = url
    this.externalLinkTarget.classList.remove("d-none")
    this.titleTarget.textContent = title

    if (id) {
      this.detailLinkTarget.href = `/machines/${id}`
      this.detailLinkTarget.classList.remove("d-none")
    }

    this.showModal()
    this.finishLoading()
  }

  showModal() {
    this.modal.show()
  }

  showMovie(event) {
    const url = event.currentTarget.href
    const youtubeMatch = url.match(/(?:https?:\/\/(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/))([\w-]{11})/)

    if (!youtubeMatch) {
      window.open(url, "_blank")
      return
    }

    event.preventDefault()

    const youtubeId = youtubeMatch[1]
    const embedUrl = `https://www.youtube.com/embed/${youtubeId}?autoplay=1&mute=1`
    const content = `
      <div class="ratio ratio-16x9">
        <iframe src="${embedUrl}" allowfullscreen allow="autoplay" style="border:0;"></iframe>
      </div>
    `
    this.showModalContent(event, content, "modal-lg")
  }

  showPdf(event) {
    const url = event.currentTarget.href
    const content = `
      <iframe src="${url}" style="width: 100%; height: 75vh; border: 0; display: block;"></iframe>
    `
    this.showModalContent(event, content, "modal-xl")
  }

  showMap(event) {
    const url = event.currentTarget.href;
    let embedUrl = url;

    // q=指定のGoogle Mapならoutput=embedを追加
    if (url.includes("google.com/maps") && url.includes("q=")) {
      // output=embed が既についていなければ付加
      if (!url.includes("output=embed")) {
        embedUrl = url + (url.includes("?") ? "&" : "?") + "output=embed";
      }
    }

    const content = `
      <iframe src="${embedUrl}" style="width: 100%; height: 75vh; border: 0; display: block;" allowfullscreen="" loading="lazy"></iframe>
    `
    this.showModalContent(event, content, "modal-xl")
  }
}
