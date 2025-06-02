// // controllers/scroll_frame_controller.js
// import { Controller } from "@hotwired/stimulus"

// export default class extends Controller {
//   static targets = ["topButton"]

//   connect() {
//     // Turbo Frameが更新されたら上へスクロール
//     this.frameLoadHandler = (event) => {
//       window.scrollTo({ top: 0, behavior: "smooth" });
//     }
//     document.addEventListener("turbo:frame-load", this.frameLoadHandler);

//     // スクロールイベントでボタン出し分け
//     this.toggleButton = this.toggleButton.bind(this);
//     window.addEventListener("scroll", this.toggleButton);

//     this.toggleButton();
//   }

//   disconnect() {
//     document.removeEventListener("turbo:frame-load", this.frameLoadHandler);
//     window.removeEventListener("scroll", this.toggleButton);
//   }

//   toggleButton() {
//     console.log("bbb")

//     if (!this.hasTopButtonTarget) return;
//     // 200px以上スクロールしたら▲ボタン表示
//     if (window.scrollY > 200) {
//       this.topButtonTarget.classList.remove("d-none");
//     } else {
//       this.topButtonTarget.classList.add("d-none");
//     }



//   }

//   scrollTop(event) {
//     event.preventDefault();
//     window.scrollTo({ top: 0, behavior: "smooth" });
//   }
// }
