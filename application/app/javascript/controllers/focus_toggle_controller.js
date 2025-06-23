import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    focusInput() {
        const input = document.querySelector("#input_repo_url")
        if (input) {
            input.focus()
        }
    }
}
