import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameSection", "chipContainer", "nameInput", "hiddenInput", "submitButton"]
  static values = { chips: Object }

  selectCategory(event) {
    const categoryName = event.target.closest("label").querySelector("span").textContent.trim()
    this.showNameSection(categoryName)
  }

  showNameSection(categoryName) {
    const chips = this.chipsValue[categoryName] || []

    this.chipContainerTarget.innerHTML = ""
    chips.forEach(name => {
      const chip = document.createElement("button")
      chip.type = "button"
      chip.textContent = name
      chip.className = "px-4 py-2 rounded-full border-2 border-primary/20 bg-white text-main-text font-medium hover:border-primary hover:bg-primary/5 transition-all cursor-pointer"
      chip.addEventListener("click", () => this.selectChip(name))
      this.chipContainerTarget.appendChild(chip)
    })

    this.nameInputTarget.value = ""
    this.hiddenInputTarget.value = ""
    this.nameSectionTarget.classList.remove("hidden")
    this.updateSubmitButton()
  }

  selectChip(name) {
    this.hiddenInputTarget.value = name
    this.nameInputTarget.value = ""

    this.chipContainerTarget.querySelectorAll("button").forEach(btn => {
      if (btn.textContent === name) {
        btn.classList.add("border-primary", "bg-primary/5", "shadow-md")
        btn.classList.remove("border-primary/20")
      } else {
        btn.classList.remove("border-primary", "bg-primary/5", "shadow-md")
        btn.classList.add("border-primary/20")
      }
    })
    this.updateSubmitButton()
  }

  inputName() {
    this.hiddenInputTarget.value = this.nameInputTarget.value.trim()

    this.chipContainerTarget.querySelectorAll("button").forEach(btn => {
      btn.classList.remove("border-primary", "bg-primary/5", "shadow-md")
      btn.classList.add("border-primary/20")
    })
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = !this.hiddenInputTarget.value
    }
  }
}
