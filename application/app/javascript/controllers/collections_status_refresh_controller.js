import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.url_value = loop_app_config.downloads_collection_path
    this.poll_interval = loop_app_config.connector_status_poll_interval
    this.loadCollections()
    this.startAutoRefresh()
  }

  loadCollections() {
    // Start the fetch request
    fetch(this.url_value, { headers: { "Accept": "text/html" } })
        .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          return response.text();
        })
        .then(html => {
          this.element.innerHTML = html
        })
        .catch(error => {
          console.error("Unable to load collections:", error)
        })
  }

  startAutoRefresh() {
    this.interval = setInterval(() => {
      this.loadCollections()
    }, this.poll_interval)
  }

  disconnect() {
    clearInterval(this.interval)
  }
}

