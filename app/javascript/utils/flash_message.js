/**
 * Displays a flash message inside a specified container.
 *
 * @param {string} type - The type of flash (e.g., 'success', 'error', 'info').
 * @param {string} message - The message text to display.
 * @param {string|Element} [container] - Optional. Can be:
 *   - a string (DOM element ID),
 *   - a DOM element (e.g., Stimulus target),
 *   - or undefined (defaults to '#flash-container' or <body>).
 *
 * If the container is not found or not provided, the message will be prepended
 * to an element with ID 'flash-container', or to document.body as a last resort.
 */
export function showFlash(type, message, container) {
    // Determine container element
    let containerElement
    if (typeof container === 'string') {
        containerElement = document.getElementById(container)
    } else if (container instanceof Element) {
        containerElement = container
    }

    // Fallback to default if nothing valid was passed
    if (!containerElement) {
        containerElement = document.getElementById('flash-container') || document.body
    }

    const wrapper = document.createElement("div")
    wrapper.innerHTML = `
    <div class="alert ${bootstrapAlertClass(type)} alert-dismissible fade show" role="alert">
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  `.trim()

    containerElement.prepend(wrapper.firstElementChild)
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
