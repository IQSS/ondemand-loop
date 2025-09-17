const selectors = {
  navDownloadsLink: '#nav-downloads',
};

export class DownloadsPage {
  visit() {
    cy.get(selectors.navDownloadsLink).click();
  }
}

export default new DownloadsPage();