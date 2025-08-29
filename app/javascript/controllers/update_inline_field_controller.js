import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
  static targets = ["display", "name", "form", "input", "label", "spinner"]
  static values = {
    fieldName: String,
    initialValue: String,
    url: String,
    errorMessage: String,
    type: String,
    method: String,
    payload: Object
  }

  connect() {
    if (this.hasInitialValueValue) {
      this.inputTarget.value = this.initialValueValue
    }
  }

  edit() {
    this.displayTarget.classList.add("d-none")
    this.formTarget.classList.remove("d-none")
    this.inputTarget.focus()
  }

  save() {
    const newValue = this.inputTarget.value.trim()
    if (!newValue || (this.hasInitialValueValue && newValue === this.initialValueValue)) {
      return this.cancel()
    }
    if (!this.hasFieldNameValue) {
      console.error('Field name not specified')
      return
    }

    const path = this.urlValue
    const requestType = this.hasTypeValue ? this.typeValue : "json"
    const method = this.hasMethodValue ? this.methodValue.toUpperCase() : "POST"
    const payload = this.hasPayloadValue ? { ...this.payloadValue } : {}
    payload[this.fieldNameValue] = newValue
    if (requestType === "form") {
      this.submitForm(path, payload, method)
    } else {
      this.submitJson(path, payload, method)
    }
  }

  submitJson(path, payload, method) {
    const csrfToken = window.loop_app_config.csrf_token
    this.showSpinner()
    fetch(path, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken,
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: "same-origin",
      body: JSON.stringify(payload)
    })
      .then(response => {
        if (!response.ok) throw new Error("Failed to update")
        return response.json()
      })
      .then(data => {
        const updatedValue = payload[this.fieldNameValue]
        this.nameTarget.textContent = updatedValue
        this.initialValueValue = updatedValue
        this.cancel()
      })
      .catch(error => {
        console.error(error)
        const message = this.hasErrorMessageValue ? this.errorMessageValue : 'Could not update field.'
        showFlash("error", message)
      })
      .finally(() => {
        this.hideSpinner()
      })
  }

  submitForm(path, payload, method) {
    this.showSpinner()
    const form = document.createElement("form")
    form.method = "POST"
    form.action = path

    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = window.loop_app_config.csrf_token
    form.appendChild(csrfInput)

    if (method !== "POST") {
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = method
      form.appendChild(methodInput)
    }

    Object.entries(payload).forEach(([key, value]) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = key
      input.value = value
      form.appendChild(input)
    })

    document.body.appendChild(form)

    const uiDelay = window.loop_app_config.ui_feedback_delay
    setTimeout(() => {
      form.submit()
    }, uiDelay)
  }

  cancel() {
    this.formTarget.classList.add("d-none")
    this.displayTarget.classList.remove("d-none")
    if (this.hasInitialValueValue) {
      this.inputTarget.value = this.initialValueValue
    }
  }

  showSpinner() {
    const { width, height } = this.formTarget.getBoundingClientRect()
    this.formTarget.style.width = `${width}px`
    this.formTarget.style.height = `${height}px`
    this.spinnerTarget.classList.remove("d-none")
    this.spinnerTarget.setAttribute('aria-busy', 'true')
    this.labelTargets.forEach(el => el.classList.add("d-none"))
  }

  hideSpinner() {
    const uiDelay = window.loop_app_config.ui_feedback_delay

    setTimeout(() => {
      this.labelTargets.forEach(el => el.classList.remove("d-none"))
      this.spinnerTarget.classList.add("d-none")
      this.formTarget.style.width = ""
      this.formTarget.style.height = ""
      this.spinnerTarget.setAttribute('aria-busy', 'false')
    }, uiDelay)
  }
}
