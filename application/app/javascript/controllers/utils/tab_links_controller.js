import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    connect() {
        const hash = window.location.hash
        if (hash) {
            const tabTriggerEl = document.querySelector(`a[href="${hash}"]`)
            if (tabTriggerEl && window.bootstrap?.Tab) {
                this.scrollActiveTabIntoView()
                const tab = new window.bootstrap.Tab(tabTriggerEl)
                tab.show()
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

    scrollActiveTabIntoView() {
        const activeTab = this.element.querySelector('.nav-link.active')
        const scrollContainer = this.element.querySelector('.nav-tabs-wrapper')

        if (activeTab && scrollContainer) {
            // Only scroll if it's not fully visible
            const tabRect = activeTab.getBoundingClientRect()
            const containerRect = scrollContainer.getBoundingClientRect()

            console.log(tabRect)
            console.log(containerRect)
            if (tabRect.left < containerRect.left || tabRect.right > containerRect.right) {
                console.log('SCROLL')
                activeTab.scrollIntoView({ behavior: 'smooth', inline: 'center' })
            }
        }
    }
}
