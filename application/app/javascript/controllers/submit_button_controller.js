import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["spinner", "label"]

    click(event) {
        event.preventDefault()

        const uiDelay = window.loop_app_config.ui_feedback_delay

        const button = event.currentTarget
        button.disabled = true

        const width = button.offsetWidth
        const height = button.offsetHeight
        button.style.width = `${width}px`
        button.style.height = `${height}px`

        this.spinnerTarget.classList.remove("d-none")
        this.labelTarget.classList.add("d-none")

        setTimeout(() => {
            this.element.closest("form").requestSubmit()
        }, uiDelay)
    }
}
