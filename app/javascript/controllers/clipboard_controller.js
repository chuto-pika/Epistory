import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    const text = this.sourceTarget.innerText

    if (navigator.clipboard) {
      navigator.clipboard.writeText(text).then(() => this.showFeedback())
    } else {
      this.fallbackCopy(text)
    }
  }

  fallbackCopy(text) {
    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.style.position = "fixed"
    textarea.style.opacity = "0"
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand("copy")
    document.body.removeChild(textarea)
    this.showFeedback()
  }

  showFeedback() {
    const button = this.buttonTarget
    const original = button.innerHTML

    button.innerHTML = '<span class="material-symbols-outlined text-xl">check</span> コピーしました'
    setTimeout(() => { button.innerHTML = original }, 2000)
  }
}
