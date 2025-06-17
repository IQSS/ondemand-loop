import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { fileDropId: String }

    toggleFileDrop(event) {
        event.preventDefault()

        const fileDropElement = document.getElementById(this.fileDropIdValue);
        if (!fileDropElement) return;

        // Get the other controller instance
        const fileDropController = this.application.getControllerForElementAndIdentifier(fileDropElement, 'file-drop');
        if (!fileDropController) return;

        fileDropController.toggleFileDrop();
    }
}
