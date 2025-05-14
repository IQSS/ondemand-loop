import { Controller } from "@hotwired/stimulus"
import { showFlash } from "../flash_message"

export default class extends Controller {
    static targets = ["icon", "feedback"]
    static values = { url: String, projectId: String }

    connect() {
        this.wasDropped = false
        this.element.addEventListener("dragover", this.dragOver.bind(this))
        //this.element.addEventListener("dragleave", this.dragLeave.bind(this))
        this.element.addEventListener("drop", this.handleDrop.bind(this))
        document.addEventListener("file-browser:file-selected", this.handleExternalSelect.bind(this))
        document.addEventListener("file-browser:dragstart", this.dragOver.bind(this))
        document.addEventListener("file-browser:dragend", this.dragLeave.bind(this))
    }

    disconnect() {
        document.removeEventListener("file-browser:file-selected", this.handleExternalSelect.bind(this))
        document.removeEventListener("file-browser:dragstart", this.dragOver.bind(this))
        document.removeEventListener("file-browser:dragend", this.dragLeave.bind(this))
    }

    dragOver(event) {
        if(event) {
            event.preventDefault();
            event.stopPropagation();
        }

        this.element.classList.add("drop-hover")
        this.iconTarget.classList.remove("d-none")
    }

    dragLeave(event) {
        if (this.wasDropped) return

        this.element.classList.remove("drop-hover")
        this.iconTarget.classList.add("d-none")
    }

    handleDrop(event) {
        event.preventDefault()
        this.wasDropped = true
        const path = event.dataTransfer.getData("text/plain")
        this.uploadPath(path)
    }

    handleExternalSelect(event) {
        event.preventDefault()

        this.element.classList.add("drop-hover")
        this.iconTarget.classList.remove("d-none")
        const path = event.detail.path
        this.uploadPath(path)
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
            if (response.ok) {
                this.showFeedback(filePath)
            } else {
                showFlash('error', `Error saving path: ${filePath}`, "file-drop-target")
                this.wasDropped = false
            }
        })
    }

    showFeedback(fileName) {
        const uiDelay = window.loop_app_config.ui_feedback_delay

        const filenameSpan = this.feedbackTarget.querySelector(".feedback-filename")
        filenameSpan.textContent = fileName
        this.feedbackTarget.classList.remove("d-none")

        setTimeout(() => {
            this.element.classList.remove("drop-hover")
            this.feedbackTarget.classList.add("d-none")
            this.iconTarget.classList.add("d-none")
            filenameSpan.textContent = ""

            const event = new CustomEvent("file-drop:file-submitted", {
                detail: { path: fileName },
                bubbles: true
            })
            this.element.dispatchEvent(event)

            this.wasDropped = false
        }, uiDelay)
    }
}
