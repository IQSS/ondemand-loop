import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["submitButton", "spinner"]

    connect() {
        this.element.addEventListener("submit", () => this.startSubmitting())
    }

    startSubmitting() {
        this.submitButtonTarget.disabled = true
        this.spinnerTarget.classList.remove("d-none")
        this.spinnerTarget.setAttribute('aria-busy', 'true')
    }

    stopSubmitting() {
        this.submitButtonTarget.disabled = false
        this.spinnerTarget.classList.add("d-none")
        this.spinnerTarget.setAttribute('aria-busy', 'false')
    }
}
