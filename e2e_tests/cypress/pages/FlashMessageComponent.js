const selectors = {
  flashAlert: '#flash-container [role="alert"]',
};

export class FlashMessageComponent {
  getFlashAlert() {
    return cy.get(selectors.flashAlert);
  }
}

export default new FlashMessageComponent();