import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        url: String,
        containerId: String,
        eventName: String
    }

    connect() {
        if (this.eventNameValue) document.addEventListener(this.eventNameValue, this.load.bind(this))
    }

    disconnect() {
        if (this.eventNameValue) document.removeEventListener(this.eventNameValue, this.load.bind(this))
    }

    load(event) {
        if (event) event.preventDefault()

        const container = document.getElementById(this.containerIdValue)
        if (!container) {
            console.error(`LazyLoaderController: Container with id '${this.containerIdValue}' not found.`)
            return
        }

        fetch(this.urlValue, {
            headers: { "Accept": "text/html" }
        })
            .then(res => res.text())
            .then(html => {
                container.classList.remove("d-none")
                container.innerHTML = html
            })
            .catch(error => {
                console.error("LazyLoaderController: Error loading content:", error)
            })
    }

    hide(event) {
        if (event) event.preventDefault()

        const container = document.getElementById(this.containerIdValue)
        if (container) {
            container.classList.add("d-none")
        } else {
            console.error(`LazyLoaderController: Container with id '${this.containerIdValue}' not found.`)
        }
    }
}
