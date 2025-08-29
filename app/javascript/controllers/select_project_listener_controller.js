import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['button', 'inputProjectName', 'inputProjectId', 'link']
    // enableOnSelect default is false

    connect() {
        document.addEventListener('select-project:change', this.handleProjectChange.bind(this))
    }
    disconnect() {
        document.removeEventListener('select-project:change', this.handleProjectChange.bind(this))
    }

    handleProjectChange(event) {
        const { projectId, projectName, projectPath } = event.detail
        const enabled = !!projectId

        if (this.hasButtonTarget) {
            this.buttonTarget.disabled = !enabled
        }

        if (this.hasInputProjectNameTarget) {
            this.inputProjectNameTarget.value = projectName || ''
        }

        if (this.hasInputProjectIdTarget) {
            this.inputProjectIdTarget.value = projectId || ''
        }

        if (this.hasLinkTarget) {
            const hasPath = !!projectName && !!projectPath

            this.linkTarget.href = hasPath ? projectPath : '#'
            this.linkTarget.classList.toggle('disabled', !hasPath)
            this.linkTarget.setAttribute('aria-disabled', String(!hasPath))
        }
    }
}
