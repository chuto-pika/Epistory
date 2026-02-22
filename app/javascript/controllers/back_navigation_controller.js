import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { step6Url: String }

  connect() {
    this._handlePopstate = () => { window.location.href = this.step6UrlValue }
    window.addEventListener("popstate", this._handlePopstate)
  }

  disconnect() {
    window.removeEventListener("popstate", this._handlePopstate)
  }
}
