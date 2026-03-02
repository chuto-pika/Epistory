import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "ratingLabel", "ratingInput", "ratingEmoji", "purposeSection", "purposeInput", "purposeLabel", "actions"]

  connect() {
    setTimeout(() => {
      this.element.classList.remove("opacity-0")
      this.element.classList.add("opacity-100")
    }, 2500)
  }

  selectRating(event) {
    const label = event.currentTarget

    this.ratingEmojiTargets.forEach((emoji) => {
      emoji.classList.remove("scale-125", "opacity-100")
      emoji.classList.add("opacity-40")
    })

    const emoji = label.querySelector("[data-survey-target='ratingEmoji']")
    emoji.classList.remove("opacity-40")
    emoji.classList.add("scale-125", "opacity-100")

    this.purposeSectionTarget.classList.remove("hidden")
    this.actionsTarget.classList.remove("hidden")
  }

  selectPurpose(event) {
    const label = event.currentTarget

    this.purposeLabelTargets.forEach((el) => {
      el.classList.remove("border-primary", "text-primary", "bg-primary/5")
      el.classList.add("border-primary/15", "text-sub-text")
    })

    const purposeLabel = label.querySelector("[data-survey-target='purposeLabel']")
    purposeLabel.classList.remove("border-primary/15", "text-sub-text")
    purposeLabel.classList.add("border-primary", "text-primary", "bg-primary/5")
  }

  skip() {
    this.purposeInputTargets.forEach((input) => { input.checked = false })
  }
}
