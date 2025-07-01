import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        event: String,
        elementId: String
    }

    connect() {
        if (this.eventValue) {
            this.element.addEventListener(this.eventValue, this.focusInput)
        }
    }

    disconnect() {
        if (this.eventValue) {
            this.element.removeEventListener(this.eventValue, this.focusInput)
        }
    }

    focusInput = () => {
        if (!this.elementIdValue) return
        const target = document.getElementById(this.elementIdValue)
        if (target) target.focus()
    }
}
