import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content", "title"]
    static values = { url: String, id: String, title: String }

    load() {
        const modalElement = document.getElementById(this.idValue);
        if (!modalElement) return;

        // Get the other controller instance
        const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal');
        if (!modalController) return;

        // Call a public method on the modal controller (you define this)
        modalController.loadFromUrl(this.urlValue, this.titleValue);
    }

    loadFromUrl(url, title) {
        if (this.hasTitleTarget && title) {
            this.titleTarget.innerText = title;
        }

        if (this.hasContentTarget) {
            this.contentTarget.innerHTML = `
        <div class="text-center py-5">
          <div class="spinner-border text-primary" role="status"></div>
        </div>
      `;

            fetch(url)
                .then(response => response.text())
                .then(html => {
                    this.contentTarget.innerHTML = html;
                });
        }

        const bsModal = new bootstrap.Modal(this.element);
        bsModal.show();
    }
}
