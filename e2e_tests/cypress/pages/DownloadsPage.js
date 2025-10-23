const selectors = {
  navDownloadsLink: '#nav-downloads',
  pageContainer: '[data-test-id="downloads-page"]',
  downloadsList: '[data-test-id="downloads-list"]',
  downloadFileRows: '[data-download-file-id]',
  downloadFileRowById: (fileId) => `[data-download-file-id="${fileId}"]`,
};

export class DownloadsPage {
  visit() {
    cy.get(selectors.navDownloadsLink).click();
  }

  assertInDownloads() {
    // Assert we're on the project details page
    cy.url().should('include', '/downloads')
    cy.title().should('match', /downloads management/i)
  }

  getPageContainer() {
    return cy.get(selectors.pageContainer);
  }

  getDownloadsList() {
    return cy.get(selectors.downloadsList);
  }

  getDownloadFileRows() {
    return cy.get(selectors.downloadFileRows);
  }

  assertAllDownloadFilesWithStatus(status) {
    // PAGE REFRESHES EVERY 5s
    // THIS IS A TRICK TO FORCE CYPRESS TO GET THE getDownloadFileRows ON EVERY RETRY
    this.getDownloadFileRows()
        .find('span.badge.file-status', { timeout: 20000 })
        .should($badges => {
          expect($badges.length).to.be.greaterThan(0)
          $badges.each((_, el) => {
            expect(el.innerText.trim()).to.eq(status)
          })
        })
  }

  getDownloadFileRowById(fileId) {
    return cy.get(selectors.downloadFileRowById(fileId));
  }
}

export default new DownloadsPage();