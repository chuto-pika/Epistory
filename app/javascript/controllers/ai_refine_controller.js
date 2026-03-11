import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["styles"]

  reveal() {
    this.stylesTarget.classList.remove("hidden")
  }
}
