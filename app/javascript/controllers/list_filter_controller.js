import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['list']

    apply(event) {
        const term = event.target.value.toLowerCase()
        if (term.length < 3) {
            this.listTarget.querySelectorAll('[data-filter-item]').forEach(item => {
                item.classList.remove('d-none')
            })
            return
        }

        this.listTarget.querySelectorAll('[data-filter-item]').forEach(item => {
            const text = item.textContent.toLowerCase()
            item.classList.toggle('d-none', !text.includes(term))
        })
    }
}