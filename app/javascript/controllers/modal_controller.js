import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["title", "subtitle", "content", "spinner", "confirmButton", "confirmText"]
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
        modalController.showSpinner();
        modalController.loadFromUrl(this.urlValue, this.titleValue);
    }

    loadFromUrl(url, title) {
        if (this.hasTitleTarget && title) {
            this.titleTarget.innerText = title;
        }

        if (this.hasContentTarget) {
            fetch(url)
                .then(response => response.text())
                .then(html => {
                    this.contentTarget.innerHTML = html;
                })
                .finally( () => this.hideSpinner())
        }

        const bsModal = new bootstrap.Modal(this.element);
        bsModal.show();
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
