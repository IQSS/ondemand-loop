import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['wrapper', 'leftBtn', 'rightBtn']

    connect() {
        this.updateButtons()
        this.addTabAnchorListener()
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

    addTabAnchorListener() {
        const hash = window.location.hash
        if (hash) {
            const tabTriggerEl = document.querySelector(`a[href="${hash}"]`)
            if (tabTriggerEl && window.bootstrap?.Tab) {
                const tab = new window.bootstrap.Tab(tabTriggerEl)
                tab.show()
                this.scrollActiveTabIntoView()
            }
        }

        this.element.querySelectorAll('a[data-bs-toggle="tab"]').forEach(el => {
            el.addEventListener('shown.bs.tab', event => {
                const href = event.target.getAttribute('href')
                if (href && history.replaceState) {
                    history.replaceState(null, '', href)
                }
            })
        })
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

    scrollActiveTabIntoView() {
        const activeTab = this.element.querySelector('.nav-link.active')
        const container = this.wrapperTarget

        if (!activeTab || !container) return

        const tabStart = activeTab.offsetLeft
        const tabEnd = tabStart + activeTab.offsetWidth
        const visibleStart = container.scrollLeft
        const visibleEnd = visibleStart + container.clientWidth

        if (tabStart < visibleStart) {
            // Scroll left to reveal the tab
            container.scrollTo({ left: tabStart - 20, behavior: 'smooth' })
        } else if (tabEnd > visibleEnd) {
            // Scroll right to reveal the tab
            container.scrollTo({ left: tabEnd - container.clientWidth + 20, behavior: 'smooth' })
        }
    }

    handleCollapseShown(event) {
        // Only react if the wrapper is inside the shown element
        if (event.target.contains(this.wrapperTarget)) {
            this.updateButtons()
        }
    }
}
