export default function SpinnerToggleMixin(Base) {
    return class extends Base {
        static targets = ["spinner", "label"]

        showSpinner(buttonElement = null) {
            const button = buttonElement || this.element.querySelector("button")
            if (!button) return

            const width = button.offsetWidth
            const height = button.offsetHeight
            button.style.width = `${width}px`
            button.style.height = `${height}px`
            button.disabled = true

            if (this.hasSpinnerTarget) {
                this.spinnerTarget.classList.remove("d-none")
            }

            if (this.hasLabelTarget) {
                this.labelTarget.classList.add("d-none")
            }
        }

        hideSpinner(buttonElement = null) {
            const button = buttonElement || this.element.querySelector("button")
            if (!button) return

            button.disabled = false
            button.style.width = ''

            if (this.hasSpinnerTarget) {
                this.spinnerTarget.classList.add("d-none")
            }

            if (this.hasLabelTarget) {
                this.labelTarget.classList.remove("d-none")
            }
        }
    }
}
