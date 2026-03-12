// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// View Transitions API + Turbo連携
document.addEventListener("turbo:before-render", (event) => {
  if (document.startViewTransition) {
    event.preventDefault()
    document.startViewTransition(() => event.detail.resume())
  }
})
