import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "overlay"]

  toggle() {
    if (this.drawerTarget.classList.contains("-translate-x-full")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.drawerTarget.classList.remove("-translate-x-full")
      this.drawerTarget.classList.add("translate-x-0")
    })
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.drawerTarget.classList.remove("translate-x-0")
    this.drawerTarget.classList.add("-translate-x-full")
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
