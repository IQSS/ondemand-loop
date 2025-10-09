const selectors = {
  navUploadsLink: '#nav-uploads',
  uploadsList: '[data-test-id="uploads-list"]',
  uploadFileRows: '[data-test-id="uploads-list"] .row[role="row"]',
  uploadFileRowByName: (filename) => `[data-test-id="uploads-list"] .row[role="row"]:contains("${filename}")`,
};

export class UploadsPage {
  visit() {
    cy.get(selectors.navUploadsLink).click();
  }

  getUploadsList() {
    return cy.get(selectors.uploadsList);
  }

  getUploadFileRows() {
    return cy.get(selectors.uploadFileRows);
  }

  getUploadFileRowByName(filename) {
    return cy.get(selectors.uploadFileRowByName(filename));
  }

  assertAllUploadFilesWithStatus(status) {
    // PAGE REFRESHES EVERY 5s
    // THIS IS A TRICK TO FORCE CYPRESS TO GET THE getDownloadFileRows ON EVERY RETRY
    this.getUploadFileRows()
        .find('span.badge.file-status', { timeout: 20000 })
        .should($badges => {
          expect($badges.length).to.be.greaterThan(0)
          $badges.each((_, el) => {
            expect(el.innerText.trim()).to.eq(status)
          })
        })
  }
}

export default new UploadsPage();