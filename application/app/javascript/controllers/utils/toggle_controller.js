import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    toggle(event) {
        event.preventDefault();

        const id = event.params.id;
        const element = document.getElementById(id);

        if (element) {
            element.classList.toggle("d-none");
        }
    }
}
