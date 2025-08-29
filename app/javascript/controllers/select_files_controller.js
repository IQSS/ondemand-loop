import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "selectAll", "submitButton"]

    connect() {
        // Delay update to allow other controllers to connect
        requestAnimationFrame(() => {
            this.updateState()
        })
    }

    toggleSelectAll(event) {
        const isChecked = event.target.checked
        this.itemTargets.forEach(checkbox => {
            checkbox.checked = isChecked
        })
        this.updateState()
    }

    updateState() {
        const allChecked = this.itemTargets.every(checkbox => checkbox.checked)
        const anyChecked = this.itemTargets.some(checkbox => checkbox.checked)

        if (this.hasSelectAllTarget) {
            this.selectAllTarget.checked = allChecked
            this.selectAllTarget.indeterminate = !allChecked && anyChecked
        }

        this.submitButtonTargets.forEach(button => {
            button.disabled = !anyChecked
        })
    }
}

