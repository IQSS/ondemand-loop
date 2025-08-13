import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "selectAll", "project", "submitButton"]

    connect() {
        // DELAY UPDATE TO ALLOW OTHER CONTROLLERS TO CONNECT AND ADD LISTENERS
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

        let hasValidProject = false
        let projectId = null
        let projectPath = null
        if (this.hasProjectTarget) {
            const selectedOption = this.projectTarget.selectedOptions[0]
            hasValidProject = selectedOption && !selectedOption.disabled
            projectId = selectedOption?.value
            projectPath = selectedOption?.dataset.projectPath
        }

        const enable = anyChecked && hasValidProject
        // Disable or enable all submit buttons
        this.submitButtonTargets.forEach(button => {
            button.disabled = !enable
        })

        const customEvent = new CustomEvent('select-files-project:change', {
            detail: { submitEnabled: enable, selectedProject: projectId, projectPath: projectPath},
            bubbles: true // Allows it to propagate up the DOM tree
        })
        this.element.dispatchEvent(customEvent)
    }
}
