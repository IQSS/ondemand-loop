import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static targets = ["form"]

    static values = {
        modalId: String,
        modalTitle: String,
        modalSubtitle: String,
        modalContent: String,
        modalConfirmText: String
    }

    click(event) {
        event.preventDefault()

        if (!this.hasModalIdValue) {
            showFlash('error', `Invalid configuration. Unable to proceed.`)
            return
        }

        const modalElement = document.getElementById(this.modalIdValue)
        const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal')

        if (modalController) {
            modalController.updateContent({
                title: this.modalTitleValue,
                subtitle: this.modalSubtitleValue,
                content: this.modalContentValue,
                confirmText: this.modalConfirmTextValue,
                onConfirm: () => this.continueRequest()
            })
        } else {
            showFlash('error', `No confirmation message. Unable to proceed.`)
        }
    }

    continueRequest() {
        const href = this.element.getAttribute("href")
        if (this.hasFormTarget) {
            this.formTarget.requestSubmit()
        } else if (href) {
            window.location.href = href
        } else {
            showFlash('error', 'No action defined for this confirmation.')
        }
    }
}
