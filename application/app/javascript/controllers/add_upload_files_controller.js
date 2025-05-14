import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { uploadFilesContainer: String, fileBrowserContainer: String }

    connect() {
        document.addEventListener("file-browser:close", this.handleClose.bind(this))
    }

    disconnect() {
        document.removeEventListener("file-browser:close", this.handleClose.bind(this))
    }

    toggleFileBrowser(event) {
        event.preventDefault()

        const uploadFilesContainer = document.getElementById(this.uploadFilesContainerValue)
        const fileBrowserContainer = document.getElementById(this.fileBrowserContainerValue)

        const isFileBrowserHidden = fileBrowserContainer.classList.contains("d-none")

        if (isFileBrowserHidden) {
            // Hide file browser, restore files list height
            fileBrowserContainer.classList.remove("d-none")
            uploadFilesContainer.classList.add("restricted-height")
        }
    }

    handleClose(event) {
        if(event) event.preventDefault()

        const uploadFilesContainer = document.getElementById(this.uploadFilesContainerValue)
        uploadFilesContainer.classList.remove("restricted-height")
    }
}
