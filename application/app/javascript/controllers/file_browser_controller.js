// app/javascript/controllers/file_browser_controller.js
import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static targets = [
        "pathInput",
        "pathDisplay",
        "pathEditor"
    ]

    static values = { url: String }

    connect() {
        this.eventNames = {
            close: `file-browser:close:${this.element.id}`,
            dragStart: `file-browser:dragstart:${this.element.id}`,
            dragEnd: `file-browser:dragend:${this.element.id}`,
            fileSelected: `file-browser:file-selected:${this.element.id}`,
            pathChange: `file-browser:path-change:${this.element.id}`
        }

        // Notify listeners of the initial path
        if (this.hasPathInputTarget) {
            this.dispatchPathChange(this.pathInputTarget.value)
        }
    }

    dispatchPathChange(path) {
        const pathChangeEvent = new CustomEvent(this.eventNames.pathChange, {
            detail: { path: path },
            bubbles: true
        })

        document.dispatchEvent(pathChangeEvent)
    }

    navigate() {
        const newPath = this.pathInputTarget.value
        const url = `${this.urlValue}?path=${encodeURIComponent(newPath)}`

        fetch(url, { headers: { Accept: "text/html" } })
            .then(res => {
                if (!res.ok) {
                    return res.json().then(data => { throw data; })
                }
                return res.text()
            })
            .then(html => {
                this.element.innerHTML = html
                this.dispatchPathChange(newPath)
            })
            .catch(error => {
                showFlash('error', error.error, this.element.id)
            })
    }

    handleDoubleClick(event) {
        const row = event.currentTarget
        const type = row.dataset.entryType
        const path = row.dataset.entryPath


        if (type === "folder") {
            this.pathInputTarget.value = path
            this.navigate()
        } else {
            this.notifyDropTarget(path)
        }
    }

    handleKeydown(event) {
        if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            this.handleDoubleClick(event); // Reuse the existing logic
        }
    }

    handleDragStart(event) {
        const path = event.currentTarget.dataset.entryPath
        event.dataTransfer.setData("text/plain", path)

        const dragStartEvent = new CustomEvent(this.eventNames.dragStart, {
            bubbles: true,
            detail: { sourcePath: path }
        })

        document.dispatchEvent(dragStartEvent)
    }

    handleDragEnd(event) {
        const dragEndEvent = new CustomEvent(this.eventNames.dragEnd, {
            bubbles: true
        })

        document.dispatchEvent(dragEndEvent)
    }

    editPath() {
        this.pathDisplayTarget.classList.add("d-none")
        this.pathEditorTarget.classList.remove("d-none")
    }

    cancelEditPath() {
        this.pathEditorTarget.classList.add("d-none")
        this.pathDisplayTarget.classList.remove("d-none")
    }

    notifyDropTarget(path) {
        const event = new CustomEvent(this.eventNames.fileSelected, {
            detail: { path: path },
            bubbles: true
        })

        document.dispatchEvent(event)
    }

    hideContainer() {
        this.element.classList.add('d-none')
        const eventName = `file-browser:close:${this.element.id}`;

        const closeEvent = new CustomEvent(this.eventNames.close, {
            bubbles: true,
        })

        document.dispatchEvent(closeEvent)
    }

    showFeedback(row) {
        const uiDelay = window.loop_app_config.ui_feedback_delay

        row.classList.add("bg-success-subtle", "text-success")

        const icon = row.querySelector("i")
        if (icon) {
            icon.classList.remove("bi-file-earmark")
            icon.classList.add("bi-check-circle-fill")
        }

        setTimeout(() => {
            row.classList.remove("bg-success-subtle", "text-success")
            if (icon) {
                icon.classList.add("bi-file-earmark")
                icon.classList.remove("bi-check-circle-fill")
            }
        }, uiDelay)
    }
}
