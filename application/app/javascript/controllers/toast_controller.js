// app/javascript/controllers/file_toast_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        delay: Number,
        containerId: String,
    }

    connect() {
        const delay = this.delayValue || 7000
        const toastElement = document.getElementById(this.containerIdValue)
        if (!toastElement) {
            console.error(`ToastController: Container with id '${this.containerIdValue}' not found.`)
            return
        }

        this.toast = new bootstrap.Toast(toastElement, {
            delay: delay
        })
    }

    show() {
        this.toast.show()
    }
}
