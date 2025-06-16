import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button", "spinner", "label"]
    static values = {
        modalId: String,
        modalTitle: String,
        modalSubtitle: String,
        modalContent: String,
        modalConfirmText: String
    }

    click(event) {
        event.preventDefault()

        if (this.hasModalIdValue) {
            const modalElement = document.getElementById(this.modalIdValue)
            const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal')

            if (modalController) {
                modalController.updateContent({
                    title: this.modalTitleValue,
                    subtitle: this.modalSubtitleValue,
                    content: this.modalContentValue,
                    confirmText: this.modalConfirmTextValue,
                    onConfirm: () => this.submit_form()
                })
            } else {
                console.warn(`Modal controller not found on #${this.modalIdValue}`)
            }
        } else {
            this.submit_form()
        }
    }

    submit_form() {
        const uiDelay = window.loop_app_config.ui_feedback_delay

        this.buttonTarget.disabled = true
        const width = this.buttonTarget.offsetWidth
        const height = this.buttonTarget.offsetHeight
        this.buttonTarget.style.width = `${width}px`
        this.buttonTarget.style.height = `${height}px`

        this.spinnerTarget.classList.remove("d-none")
        this.labelTarget.classList.add("d-none")

        setTimeout(() => {
            this.element.requestSubmit()
        }, uiDelay)
    }
}
