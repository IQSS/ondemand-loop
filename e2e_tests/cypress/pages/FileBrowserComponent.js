const selectors = {
  fileBrowserHomeButton: '[data-test-id="fb-home-btn"]',
  fileBrowserCloseButton: '[data-test-id="fb-close-btn"]',
  // THIS USE REGULAR EXPRESSIONS TO MATCH THE FILE FULL PATH WITH JUST THE FILENAME
  fileBrowserFileRow: (filename) => `li[data-entry-path*="${filename}"]`,
};

export class FileBrowserComponent {

  clickFileBrowserHome() {
    cy.get(selectors.fileBrowserHomeButton).click();
  }

  selectFileByDoubleClick(filename) {
    cy.get(selectors.fileBrowserFileRow(filename)).dblclick();
  }

  closeFileBrowser() {
    cy.get(selectors.fileBrowserCloseButton).click();
  }
}

export default new FileBrowserComponent();
