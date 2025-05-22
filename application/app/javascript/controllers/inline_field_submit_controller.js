import { Controller } from "@hotwired/stimulus"
import { showFlash } from "../flash_message"

export default class extends Controller {
    static targets = ["form", "input", "label", "button", "cancel", "spinner"]

    static values = {
        url: String,
        fieldName: String,
        type: String // 'json' or 'form'
    }

    connect() {
        //this.formTarget.classList.add("d-none")
    }

    showForm(event) {
        event.preventDefault()
        this.formTarget.classList.remove("d-none")
        this.buttonTarget.classList.add("d-none")
        this.inputTarget.focus()
    }

    showSpinner() {
        const { width, height } = this.formTarget.getBoundingClientRect()
        this.formTarget.style.width = `${width}px`
        this.formTarget.style.height = `${height}px`
        this.spinnerTarget.classList.remove("d-none")
        this.labelTargets.forEach(el => el.classList.add("d-none"))
    }

    hideSpinner() {
        const uiDelay = window.loop_app_config.ui_feedback_delay

        setTimeout(() => {
            this.labelTargets.forEach(el => el.classList.remove("d-none"))
            //this.formTarget.classList.remove("invisible")
            this.spinnerTarget.classList.add("d-none")
            this.formTarget.style.width = ""
            this.formTarget.style.height = ""
        }, uiDelay)
    }

    cancel(event) {
        event.preventDefault()
        this.formTarget.classList.add("d-none")
        this.buttonTarget.classList.remove("d-none")
        this.inputTarget.value = ""
    }

    submit(event) {
        event.preventDefault()
        const value = this.inputTarget.value
        const fieldName = this.fieldNameValue

        if (this.typeValue === "form") {
            this.submitForm(fieldName, value)
        } else {
            this.submitJson(fieldName, value, event)
        }
    }

    submitJson(fieldName, value, event) {
        const payload = {}
        payload[fieldName] = value

        const csrfToken = window.loop_app_config.csrf_token

        this.showSpinner()

        fetch(this.urlValue, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify(payload)
        })
            .then(response => {
                if (!response.ok) throw new Error("Request failed")
                return response.json()
            })
            .then(data => {
                this.cancel(event)
                showFlash("success", window.loop_app_config.i18n.inline_field.submit.success)
            })
            .catch(error => {
                console.error("Submission failed", error)
                showFlash("error", window.loop_app_config.i18n.inline_field.submit.error)
            })
            .finally(() => {
                this.hideSpinner()
            })
    }

    submitForm(fieldName, value) {
        this.showSpinner()
        const uiDelay = window.loop_app_config.ui_feedback_delay

        const form = document.createElement("form")
        form.method = "POST"
        form.action = this.urlValue

        // Add CSRF token
        const csrfInput = document.createElement("input")
        csrfInput.type = "hidden"
        csrfInput.name = "authenticity_token"
        csrfInput.value = window.loop_app_config.csrf_token
        form.appendChild(csrfInput)

        // Add field
        const fieldInput = document.createElement("input")
        fieldInput.type = "hidden"
        fieldInput.name = fieldName
        fieldInput.value = value
        form.appendChild(fieldInput)

        document.body.appendChild(form)

        setTimeout(() => {
            form.submit()
        }, uiDelay)
    }
}
