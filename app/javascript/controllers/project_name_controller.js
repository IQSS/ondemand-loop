import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static targets = ["display", "name", "form", "input"]
    static values = {
        initialName: String,
        projectId: String,
        url: String
    }

    connect() {
        this.inputTarget.value = this.initialNameValue
    }

    edit() {
        this.displayTarget.classList.add("d-none")
        this.formTarget.classList.remove("d-none")
        this.inputTarget.focus()
    }

    save() {
        const newName = this.inputTarget.value.trim()
        if (!newName || newName === this.initialNameValue) {
            return this.cancel()
        }

        const path = this.urlValue
        const csrfToken = window.loop_app_config.csrf_token
        fetch(path, {
            method: "PUT",
            headers: {
                "X-CSRF-Token": csrfToken,
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            credentials: "same-origin",
            body: JSON.stringify({ name: newName })
        })
            .then(response => {
                if (!response.ok) throw new Error("Failed to update project name")
                return response.json()
            })
            .then(data => {
                this.nameTarget.textContent = newName
                this.initialNameValue = newName
                this.cancel()
            })
            .catch(error => {
                console.error(error)
                showFlash("error", window.loop_app_config.i18n.project_name.save.error)
            })
    }

    cancel() {
        this.formTarget.classList.add("d-none")
        this.displayTarget.classList.remove("d-none")
        this.inputTarget.value = this.initialNameValue
    }
}
