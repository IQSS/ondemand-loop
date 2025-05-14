// app/javascript/controllers/file_browser_controller.js
import { Controller } from "@hotwired/stimulus"
import { showFlash } from "../flash_message"

export default class extends Controller {
    static targets = [
        "pathInput",
        "pathDisplay",
        "pathEditor"
    ]

    static values = { url: String }

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
            })
            .catch(error => {
                showFlash('error', error.error, "file-browser")
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

    handleDragStart(event) {
        const path = event.currentTarget.dataset.entryPath
        event.dataTransfer.setData("text/plain", path)

        const dragStartEvent = new CustomEvent('file-browser:dragstart', {
            bubbles: true,
            detail: { sourcePath: path }
        })

        document.dispatchEvent(dragStartEvent)
    }

    handleDragEnd(event) {
        const dragEndEvent = new CustomEvent('file-browser:dragend', {
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
        const dropTargetId = window.loop_app_config.file_drop_target_id || 'file-drop-target'
        const dropTarget = document.getElementById(dropTargetId)
        if (!dropTarget || !dropTarget.dataset.controller?.includes("file-drop")) return
        const event = new CustomEvent("file-browser:file-selected", {
            detail: { path: path },
            bubbles: true
        })

        document.dispatchEvent(event)
    }

    hideContainer() {
        const parent = this.element.parentElement
        parent.classList.add('d-none')

        const closeEvent = new CustomEvent('file-browser:close', {
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
