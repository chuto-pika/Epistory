import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("lp-revealed")
            this.observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.15 }
    )

    this.itemTargets.forEach((item) => {
      item.classList.add("lp-reveal-hidden")
      this.observer.observe(item)
    })
  }

  disconnect() {
    this.observer.disconnect()
  }
}
