import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  async save() {
    const button = this.buttonTarget
    const originalHTML = button.innerHTML

    button.innerHTML = '<span class="material-symbols-outlined text-xl animate-spin">progress_activity</span> 作成中...'
    button.disabled = true

    try {
      const { default: html2canvas } = await import("html2canvas")

      const source = this.sourceTarget
      source.style.position = "absolute"
      source.style.left = "0"
      source.style.top = "0"
      source.style.zIndex = "-9999"
      source.style.display = "block"

      const canvas = await html2canvas(source, {
        scale: 1,
        useCORS: true,
        backgroundColor: "#C5CEB5",
        width: 1080,
        windowWidth: 1080
      })

      source.style.display = "none"
      source.style.position = ""
      source.style.left = ""
      source.style.top = ""
      source.style.zIndex = ""

      const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)

      if (isIOS) {
        const dataURL = canvas.toDataURL("image/png")
        const newTab = window.open()
        if (newTab) {
          newTab.document.write(`<img src="${dataURL}" style="max-width:100%">`)
          newTab.document.title = "メッセージ画像 - 長押しで保存"
        }
      } else {
        canvas.toBlob((blob) => {
          const url = URL.createObjectURL(blob)
          const a = document.createElement("a")
          a.href = url
          a.download = "epistory-message.png"
          document.body.appendChild(a)
          a.click()
          document.body.removeChild(a)
          URL.revokeObjectURL(url)
        }, "image/png")
      }

      button.innerHTML = '<span class="material-symbols-outlined text-xl">check</span> 保存しました'
      setTimeout(() => { button.innerHTML = originalHTML }, 2000)
    } catch (error) {
      console.error("Image export failed:", error)
      button.innerHTML = '<span class="material-symbols-outlined text-xl">error</span> エラーが発生しました'
      setTimeout(() => { button.innerHTML = originalHTML }, 2000)
    } finally {
      button.disabled = false
    }
  }
}
