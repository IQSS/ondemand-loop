import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['button', 'field', 'link']
    static values = { enableOnSelect: Boolean }
    // enableOnSelect default is false

    connect() {
        document.addEventListener('select-files-project:change', this.handleProjectChange.bind(this))
    }
    disconnect() {
        document.removeEventListener('select-files-project:change', this.handleProjectChange.bind(this))
    }

    handleProjectChange(event) {
        const { submitEnabled, selectedProject, projectPath } = event.detail
        const enabled = this.enableOnSelectValue ? !!selectedProject : submitEnabled

        if (this.hasButtonTarget) {
            this.buttonTarget.disabled = !enabled
        }

        if (this.hasFieldTarget) {
            this.fieldTarget.value = selectedProject || ''
        }

        if (this.hasLinkTarget) {
            const hasPath = !!selectedProject && !!projectPath

            this.linkTarget.href = hasPath ? projectPath : '#'
            this.linkTarget.classList.toggle('disabled', !hasPath)
            this.linkTarget.setAttribute('aria-disabled', String(!hasPath))
        }
    }
}
