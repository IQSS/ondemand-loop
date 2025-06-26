import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['wrapper', 'leftBtn', 'rightBtn']

    connect() {
        this.updateButtons()
        this.wrapperTarget.addEventListener('scroll', this.updateButtons.bind(this))
        window.addEventListener('resize', this.updateButtons.bind(this))

        // Handle collapsed sections becoming visible
        this.handleCollapseShown = this.handleCollapseShown.bind(this)
        document.addEventListener('shown.bs.collapse', this.handleCollapseShown)
    }

    disconnect() {
        this.wrapperTarget.removeEventListener('scroll', this.updateButtons.bind(this))
        window.removeEventListener('resize', this.updateButtons.bind(this))
        document.removeEventListener('shown.bs.collapse', this.handleCollapseShown)
    }

    scrollLeft() {
        this.wrapperTarget.scrollBy({ left: -150, behavior: 'smooth' })
    }

    scrollRight() {
        this.wrapperTarget.scrollBy({ left: 150, behavior: 'smooth' })
    }

    updateButtons() {
        const el = this.wrapperTarget

        const scrollLeft = el.scrollLeft
        const scrollRight = el.scrollWidth - el.clientWidth - scrollLeft

        this.leftBtnTarget.disabled = scrollLeft <= 0
        this.rightBtnTarget.disabled = scrollRight <= 1
    }

    handleCollapseShown(event) {
        // Only react if the wrapper is inside the shown element
        if (event.target.contains(this.wrapperTarget)) {
            this.updateButtons()
        }
    }
}
