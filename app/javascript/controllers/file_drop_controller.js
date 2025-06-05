import { Controller } from "@hotwired/stimulus"
import { showFlash } from "../flash_message"

export default class extends Controller {
    static targets = ["icon", "feedback"]
    static values = { url: String, fileBrowserId: String }

    connect() {
        this.wasDropped = false
        this.element.addEventListener("dragover", this.dragOver.bind(this))
        //this.element.addEventListener("dragleave", this.dragLeave.bind(this))
        this.element.addEventListener("drop", this.handleDrop.bind(this))

        document.addEventListener(`file-browser:file-selected:${this.fileBrowserIdValue}`, this.handleExternalSelect.bind(this))
        document.addEventListener(`file-browser:dragstart:${this.fileBrowserIdValue}`, this.dragOver.bind(this))
        document.addEventListener(`file-browser:dragend:${this.fileBrowserIdValue}`, this.dragLeave.bind(this))
    }

    disconnect() {
        document.removeEventListener(`file-browser:file-selected:${this.fileBrowserIdValue}`, this.handleExternalSelect.bind(this))
        document.removeEventListener(`file-browser:dragstart:${this.fileBrowserIdValue}`, this.dragOver.bind(this))
        document.removeEventListener(`file-browser:dragend:${this.fileBrowserIdValue}`, this.dragLeave.bind(this))
    }

    dragOver(event) {
        if(event) {
            event.preventDefault();
            event.stopPropagation();
        }

        this.showDroppingZone()
    }

    dragLeave(event) {
        if (this.wasDropped) return

        this.hideDroppingZone()
    }

    handleDrop(event) {
        event.preventDefault()
        this.wasDropped = true
        const filePath = event.dataTransfer.getData("text/plain")
        this.uploadPath(filePath)
    }

    handleExternalSelect(event) {
        event.preventDefault()

        this.showDroppingZone()
        const filePath = event.detail.path
        this.uploadPath(filePath)
    }

    uploadPath(filePath) {
        const path = this.urlValue
        const csrfToken = window.loop_app_config.csrf_token
        fetch(path, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({ path: filePath })
        }).then(response => {
            return response.json().then(data => {
                if (response.ok) {
                    this.showFeedback(filePath, data.message); // pass message to showFeedback
                } else {
                    const msg = data.message || `${window.loop_app_config.i18n.drop.path.save_error} ${filePath}`;
                    showFlash('error', msg, this.element.id);
                    this.hideDroppingZone()
                    this.wasDropped = false
                }
            });
        }).catch(error => {
            console.error('Network error:', error);
            showFlash('error', `${window.loop_app_config.i18n.drop.path.network_error} ${filePath}`, this.element.id);
            this.wasDropped = false;
        });
    }

    showFeedback(filePath, message) {
        const uiDelay = window.loop_app_config.ui_feedback_delay

        this.feedbackTarget.textContent = message
        this.feedbackTarget.classList.remove("d-none")

        setTimeout(() => {
            this.hideDroppingZone()
            this.feedbackTarget.classList.add("d-none")
            this.feedbackTarget.textContent = ""

            const event = new CustomEvent(`file-drop:file-submitted:${this.element.id}`, {
                detail: { path: filePath },
                bubbles: true
            })
            this.element.dispatchEvent(event)

            this.wasDropped = false
        }, uiDelay)
    }

    showDroppingZone() {
        this.element.classList.add("drop-hover")
        this.iconTarget.classList.remove("d-none")
    }

    hideDroppingZone() {
        this.element.classList.remove("drop-hover")
        this.iconTarget.classList.add("d-none")
    }
}
