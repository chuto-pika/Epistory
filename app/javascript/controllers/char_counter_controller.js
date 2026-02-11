import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "current"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const count = this.inputTarget.value.length
    this.currentTarget.textContent = count

    this.counterTarget.classList.remove("text-yellow-600", "text-red-600")
    this.inputTarget.classList.remove("border-red-400")

    if (count > this.maxValue) {
      this.counterTarget.classList.add("text-red-600")
      this.inputTarget.classList.add("border-red-400")
    } else if (count > this.maxValue * 0.9) {
      this.counterTarget.classList.add("text-yellow-600")
    }
  }
}
