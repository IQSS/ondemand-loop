import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        url: String,
        interval: Number,
        containerId: String,
        eventName: String
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

        fetch(this.urlValue, {
            headers: { "Accept": "text/html" }
        })
            .then(res => res.text())
            .then(html => {
                this.container.classList.remove("d-none")
                this.container.innerHTML = html
            })
            .catch(error => {
                console.error("LazyLoaderController: Error loading content:", error)
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
            this.load()
            this.container.classList.remove('d-none')
        } else {
            this.container.classList.add('d-none')
        }
    }

    startAutoRefresh() {
        this.interval = setInterval(() => {
            this.load()
        }, this.intervalValue)
    }
}
