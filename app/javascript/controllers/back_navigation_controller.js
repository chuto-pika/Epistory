import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { step6Url: String }

  connect() {
    // ブラウザの「戻る」ボタンでStep 6に戻るよう履歴を操作する
    // history: [..., X, show] → [..., X, step6, show]
    const currentUrl = window.location.href
    history.replaceState(null, "", this.step6UrlValue)
    history.pushState(null, "", currentUrl)
  }
}
