import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    connect() {
        const hash = window.location.hash
        if (hash) {
            const tabTriggerEl = document.querySelector(`a[href="${hash}"]`)
            if (tabTriggerEl && window.bootstrap?.Tab) {
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
}
