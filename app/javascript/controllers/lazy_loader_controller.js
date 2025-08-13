import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static values = {
        url: String,
        interval: Number,
        stopOnInactive: Boolean,
        containerId: String,
        eventName: String,
        reloadOnToggle: { type: Boolean, default: true },
        displayErrors: { type: Boolean, default: false }
    }

    connect() {
        this.container = this.element
        if (this.containerIdValue) this.container = document.getElementById(this.containerIdValue)

        if (this.eventNameValue) {
            this.boundLoad = this.load.bind(this)
            document.addEventListener(this.eventNameValue, this.boundLoad)
        }

        if (this.intervalValue) {
            this.load()
            this.startAutoRefresh()
        }

        this.hasLoadedOnToggle = false
    }

    disconnect() {
        if (this.eventNameValue && this.boundLoad) document.removeEventListener(this.eventNameValue, this.boundLoad)

        if (this.intervalValue) clearInterval(this.interval)
    }

    load(event) {
        if (event) event.preventDefault()

        if (!this.container) {
            console.error(`LazyLoaderController: Container with id '${this.containerIdValue}' not found.`)
            return
        }

        this.container.classList.remove("d-none")

        fetch(this.urlValue, {
            headers: { "Accept": "text/html", 'X-Requested-With': 'XMLHttpRequest' }
        }).then(response => {
                if (!response.ok) {
                    const contentType = response.headers.get('content-type');
                    if (contentType && contentType.includes('application/json')) {
                        return response.json().then(data => { throw data; });
                    } else {
                        throw { error: window.loop_app_config.i18n.generic_server_error };
                    }
                }
                return response.text();
            })
            .then(html => {
                this.container.innerHTML = html
            })
            .catch(error => {
                if (this.displayErrorsValue) {
                    // CLEAR CONTENT
                    this.container.innerHTML = ''
                    const message = error.error ?? window.loop_app_config.i18n.generic_server_error
                    showFlash('error', message, this.container)
                } else {
                    console.error("LazyLoaderController: Error loading content:", error)
                }
            })
    }

    hide(event) {
        if (event) event.preventDefault()

        if (this.container) {
            this.container.classList.add("d-none")
        } else {
            console.error(`LazyLoaderController: Container with id '${this.containerIdValue}' not found.`)
        }
    }

    toggle(event) {
        if (event) event.preventDefault()

        if (!this.container) {
            console.error(`LazyLoaderController: Container with id '${this.containerIdValue}' not found.`)
            return
        }

        const isHidden = this.container.classList.contains('d-none')

        if (isHidden) {
            if (!this.hasLoadedOnToggle || this.reloadOnToggleValue) {
                this.load()
                this.hasLoadedOnToggle = true
            }

            this.container.classList.remove('d-none')
        } else {
            this.container.classList.add('d-none')
        }
    }

    startAutoRefresh() {
        this.interval = setInterval(() => {
            if(this.stopOnInactiveValue && document.visibilityState === 'hidden'){
                console.log('Reload request skipped du to user inactivity')
            } else {
                this.load()
            }
        }, this.intervalValue)
    }
}
