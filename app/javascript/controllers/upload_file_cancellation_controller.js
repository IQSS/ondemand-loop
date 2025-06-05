import { Controller } from "@hotwired/stimulus"
import SpinnerToggleMixin from "../mixins/spinner_toggle"
import { showFlash } from "../flash_message"

// Connects to data-controller="upload-cancellation"
export default class extends SpinnerToggleMixin(Controller) {
    static values = { url: String }

    cancel(event) {
        event.preventDefault()
        const button = event.currentTarget
        this.showSpinner(button)

        const path = this.urlValue
        const csrfToken = window.loop_app_config.csrf_token
        const uiDelay = window.loop_app_config.ui_feedback_delay

        fetch(path, {
            method: "POST",
            headers: {
                "X-CSRF-Token": csrfToken,
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            credentials: "same-origin"
        }).then(response => {
            if (response.ok) {
                this.element.classList.add("disabled") // greys‑out the button
            } else {
                console.error("Cancellation failed", response.statusText)
            }
        }).catch(err => {
            console.error(err)
            showFlash("alert", window.loop_app_config.i18n.upload.cancel.error)
        }).finally(() => {
            setTimeout(() => {
                this.hideSpinner(button)
            }, uiDelay)
        })
    }
}
