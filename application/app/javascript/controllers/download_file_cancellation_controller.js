import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="download-cancellation"
export default class extends Controller {
    static values = { url: String }

    cancel(event) {
        event.preventDefault()          // stop the "#" navigation

        const path = this.urlValue
        const csrfToken = window.loop_app_config.csrf_token

        fetch(path, {
            method: "POST",
            headers: {
                "X-CSRF-Token": csrfToken,
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            credentials: "same-origin"
        })
            .then(response => {
                if (response.ok) {
                    // Optional UI feedback
                    this.element.classList.add("disabled") // greys‑out the button
                    // flashToast("Download cancelled") – if you use a toast helper
                } else {
                    console.error("Cancellation failed", response.statusText)
                }
            })
            .catch(err => console.error(err))
    }
}
