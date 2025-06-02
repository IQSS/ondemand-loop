import { Controller } from '@hotwired/stimulus'

// Usage:
// <div data-controller="utils--icon-toggle"
//      data-utils--icon-toggle-icon-on-value="bi-chevron-down"
//      data-utils--icon-toggle-icon-off-value="bi-chevron-right"
//      data-action="click->utils--icon-toggle#toggle">
//   <i data-utils--icon-toggle-target="icon" class="bi bi-chevron-right"></i>
// </div>

export default class extends Controller {
    static targets = ['icon']
    static values = {
        iconOn: String,
        iconOff: String
    }

    toggle() {
        this.iconTargets.forEach((icon) => {
            const hasOn = icon.classList.contains(this.iconOnValue)

            icon.classList.toggle(this.iconOnValue, !hasOn)
            icon.classList.toggle(this.iconOffValue, hasOn)
        })
    }
}
