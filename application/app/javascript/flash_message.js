// app/javascript/utils/flash.js
export function showFlash(type, message) {
    const container = document.querySelector("#flash-container") || document.body

    const wrapper = document.createElement("div")
    wrapper.innerHTML = `
    <div class="alert ${bootstrapAlertClass(type)} alert-dismissible fade show" role="alert">
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  `.trim()

    container.prepend(wrapper.firstElementChild)
}

function bootstrapAlertClass(type) {
    switch (type) {
        case "error":
        case "alert":
        case "danger":
            return "alert-danger"
        case "warning":
            return "alert-warning"
        case "info":
            return "alert-info"
        case "success":
        case "notice":
            return "alert-success"
        default:
            return "alert-secondary"
    }
}
