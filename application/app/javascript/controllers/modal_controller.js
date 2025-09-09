import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static targets = ["title", "subtitle", "content", "spinner", "confirmText"]
    static values = { url: String, id: String, title: String }

    connect() {
        // Initialize the Bootstrap Modal instance on connect
        this.modal = bootstrap.Modal.getOrCreateInstance(this.element)
        this.confirmCallback = null
    }


    /**
     * Update modal content dynamically via trigger controller
     * @param {Object} options
     * @param {String} options.title - Title text
     * @param {String} options.subtitle - Subtitle text
     * @param {String} options.content - Body content
     * @param {String} options.confirmText - Text for confirm button
     * @param {Function} options.onConfirm - Callback function
     */
    updateContent({ title, subtitle, content, confirmText, onConfirm }) {
        if (title) this.titleTarget.textContent = title
        if (subtitle) this.subtitleTarget.textContent = subtitle
        if (content) this.contentTarget.textContent = content
        if (confirmText) this.confirmTextTarget.textContent = confirmText

        this.confirmCallback = typeof onConfirm === 'function' ? onConfirm : null

        this.modal.show();
    }

    confirm(event) {
        this.modal.hide()
        if (this.confirmCallback) this.confirmCallback()
    }

    load() {
        const modalElement = document.getElementById(this.idValue);
        if (!modalElement) return;

        // Get the other controller instance
        const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal');
        if (!modalController) return;

        // Call a public method on the modal controller (you define this)
        modalController.clearContent();
        modalController.showSpinner();
        modalController.loadFromUrl(this.urlValue, this.titleValue);
    }

    loadFromUrl(url, title) {
        if (this.hasTitleTarget && title) {
            this.titleTarget.innerText = title;
        }

        if (this.hasContentTarget) {
            fetch(url, {
                headers: { "Accept": "text/html", 'X-Requested-With': 'XMLHttpRequest' }
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    return response.text();
                })
                .then(html => {
                    this.contentTarget.innerHTML = html;
                })
                .catch(error => {
                    console.error("Modal load error", error)
                    showFlash("error", window.loop_app_config.i18n.modal.load.error, this.contentTarget)
                })
                .finally( () => this.hideSpinner())
        }

        const bsModal = new bootstrap.Modal(this.element);
        bsModal.show();
    }

    clearContent() {
        if (this.hasTitleTarget) this.titleTarget.textContent = ''
        if (this.hasSubtitleTarget) this.subtitleTarget.textContent = ''
        if (this.hasContentTarget) this.contentTarget.innerHTML = ''
        if (this.hasConfirmTextTarget) this.confirmTextTarget.textContent = ''

        this.confirmCallback = null
    }

    showSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.remove("d-none")
        }
    }

    hideSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.add("d-none")
        }
    }
}
