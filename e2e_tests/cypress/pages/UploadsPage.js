const selectors = {
  navUploadsLink: '#nav-uploads',
};

export class UploadsPage {
  visit() {
    cy.get(selectors.navUploadsLink).click();
  }
}

export default new UploadsPage();