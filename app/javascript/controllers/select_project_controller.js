// app/javascript/controllers/select_project_controller.js
import { Controller } from '@hotwired/stimulus'
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static targets = ['displayLabel', 'spinner']
    static values = { type: String }

    connect() {
        // DELAY UPDATE TO ALLOW OTHER CONTROLLERS TO CONNECT AND ADD LISTENERS
        requestAnimationFrame(() => {
            // On connect, try to find the first item in the dropdown list
            const firstLink = this.element.querySelector('[data-project-id]')
            if (firstLink) {
                this.updateDisplay(firstLink)
                this.selectedProjectId = firstLink.dataset.projectId
                this.dispatchSelectedProject(firstLink.dataset.projectId, firstLink.dataset.projectName, firstLink.dataset.projectPath)
            }
        })
    }

    chooseProject(event) {
        event.preventDefault()
        const link = event.currentTarget
        const projectId = link.dataset.projectId
        const projectName = link.dataset.projectName
        const projectPath = link.dataset.projectPath

        if (projectId !== this.selectedProjectId) {
            const requestType = this.hasTypeValue ? this.typeValue : 'json'
            this.showSpinner()
            if (requestType === 'form') {
                this.submitForm(projectPath)
            } else {
                this.submitJson(projectPath)
                    .then(() => {
                        this.selectedProjectId = projectId
                        this.updateDisplay(link)
                        this.dispatchSelectedProject(projectId, projectName, projectPath)
                    })
                    .catch(error => {
                        const message = error?.error ?? window.loop_app_config.i18n.generic_server_error
                        showFlash('error', message)
                    })
                    .finally(() => {
                        this.hideSpinner()
                    })
            }
        } else {
            this.updateDisplay(link)
            this.dispatchSelectedProject(projectId, projectName, projectPath)
        }
    }

    submitJson(projectPath) {
        const csrfToken = window.loop_app_config.csrf_token
        return fetch(`${projectPath}/set_active`, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-CSRF-Token': csrfToken,
                'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'same-origin'
        }).then(response => {
            if (!response.ok) return response.json().then(data => Promise.reject(data))
        })
    }

    submitForm(projectPath) {
        const path = `${projectPath}/set_active`
        const form = document.createElement('form')
        form.method = 'POST'
        form.action = path

        const csrfInput = document.createElement('input')
        csrfInput.type = 'hidden'
        csrfInput.name = 'authenticity_token'
        csrfInput.value = window.loop_app_config.csrf_token
        form.appendChild(csrfInput)

        const hash = window.location.hash
        if (hash && hash.length > 1) {
            const anchorInput = document.createElement('input')
            anchorInput.type = 'hidden'
            anchorInput.name = 'anchor'
            anchorInput.value = hash.substring(1)
            form.appendChild(anchorInput)
        }

        document.body.appendChild(form)

        const uiDelay = window.loop_app_config.ui_feedback_delay
        setTimeout(() => {
            form.submit()
        }, uiDelay)
    }

    updateDisplay(link) {
        const projectName = link.textContent.trim()
        if (this.hasDisplayLabelTarget) {
            this.displayLabelTarget.textContent = projectName
        }
    }

    dispatchSelectedProject(projectId, projectName, projectPath) {
        const customEvent = new CustomEvent('select-project:change', {
            detail: { projectId: projectId, projectName: projectName, projectPath: projectPath },
            bubbles: true
        })
        this.element.dispatchEvent(customEvent)
    }

    showSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.remove('d-none')
        }
    }

    hideSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.add('d-none')
        }
    }
}
