const selectors = {
  // Navigation selectors
  repositoriesDropdown: '#repositoriesDropdown',
  zenodoNavItem: '#nav-zenodo',

  // Landing page selectors
  breadcrumbs: 'nav[aria-label="Breadcrumb"]',
  breadcrumbHome: '.breadcrumb .breadcrumb-item:first-child',
  breadcrumbActive: '.breadcrumb .breadcrumb-item.active',
  zenodoLogoContainer: 'div[data-test="zenodo-logo-container"]',
  zenodoLogo: 'div[data-test="zenodo-logo-container"] img',
  zenodoProjectLink: 'div[data-test="zenodo-logo-container"] a',

  // Search functionality
  searchForm: '#zenodo-search-form',
  searchInput: 'form input[name="query"]',
  searchSubmitButton: 'input[type="submit"]',
  serverSchemeField: 'input[name="server_scheme"]',
  serverPortField: 'input[name="server_port"]',

  // Results table
  resultsCard: '.card',
  resultsHeader: '.card-header',
  resultsTable: 'table.table-striped',
  resultsTableBody: 'table tbody',
  resultsTableRows: 'table tbody tr',
  noResultsAlert: '.alert.alert-warning',

  // Pagination
  paginationNav: 'nav[aria-label="Search result pagination"]',
  nextPageLink: 'a[title="Next page"]',
  prevPageLink: 'a[title="Previous page"]',

  // Record page selectors
  recordActionsBar: '.d-flex.justify-content-between.align-items-center.mt-3',
  recordTitle: 'h2.mb-0.me-2.fs-4.h5',
  createBundleButton: 'button:contains("Create Bundle")',
  openRecordLink: 'a[title*="Open record"]',

  // Record files
  recordFiles: '[data-test="record-files"]',
  filesList: '.list-group',
  fileItems: '.list-group-item',
};

export class Zenodo {
  // Navigation methods
  navigateToZenodo() {
    cy.get(selectors.repositoriesDropdown).click();
    cy.get(selectors.zenodoNavItem).click();
    cy.get('body').should('contain', 'Zenodo');
  }

  // Landing page methods
  getBreadcrumbs() {
    return cy.get(selectors.breadcrumbs);
  }

  getBreadcrumbHome() {
    return cy.get(selectors.breadcrumbHome);
  }

  getBreadcrumbActive() {
    return cy.get(selectors.breadcrumbActive);
  }

  getZenodoLogoContainer() {
    return cy.get(selectors.zenodoLogoContainer);
  }

  getZenodoLogo() {
    return cy.get(selectors.zenodoLogo);
  }

  getZenodoProjectLink() {
    return cy.get(selectors.zenodoProjectLink);
  }

  // Search functionality
  getSearchForm() {
    return cy.get(selectors.searchForm);
  }

  getSearchInput() {
    return cy.get(selectors.searchInput);
  }

  getSearchSubmitButton() {
    return cy.get(selectors.searchSubmitButton);
  }

  getServerSchemeField() {
    return cy.get(selectors.serverSchemeField);
  }

  getServerPortField() {
    return cy.get(selectors.serverPortField);
  }

  searchRecords(query) {
    this.getSearchInput().clear().type(query);
    this.getSearchSubmitButton().click();
  }

  // Results functionality
  getResultsCard() {
    return cy.get(selectors.resultsCard);
  }

  getResultsHeader() {
    return cy.get(selectors.resultsHeader);
  }

  getResultsTable() {
    return cy.get(selectors.resultsTable);
  }

  getResultsTableBody() {
    return cy.get(selectors.resultsTableBody);
  }

  getResultsTableRows() {
    return cy.get(selectors.resultsTableRows);
  }

  getNoResultsAlert() {
    return cy.get(selectors.noResultsAlert);
  }

  clickRecordByIndex(index) {
    this.getResultsTableRows().eq(index).find('a').first().click();
  }

  // Pagination
  getPaginationNav() {
    return cy.get(selectors.paginationNav);
  }

  getNextPageLink() {
    return cy.get(selectors.nextPageLink);
  }

  getPrevPageLink() {
    return cy.get(selectors.prevPageLink);
  }

  clickNextPage() {
    this.getNextPageLink().click();
  }

  clickPrevPage() {
    this.getPrevPageLink().click();
  }

  // Record page methods
  getRecordActionsBar() {
    return cy.get(selectors.recordActionsBar);
  }

  getRecordTitle() {
    return cy.get(selectors.recordTitle);
  }

  getCreateBundleButton() {
    return cy.get(selectors.createBundleButton);
  }

  getOpenRecordLink() {
    return cy.get(selectors.openRecordLink);
  }

  clickCreateBundle() {
    this.getCreateBundleButton().click();
  }

  clickOpenRecord() {
    this.getOpenRecordLink().click();
  }

  // Record files
  getRecordFiles() {
    return cy.get(selectors.recordFiles);
  }

  getFilesList() {
    return cy.get(selectors.filesList);
  }

  getFileItems() {
    return cy.get(selectors.fileItems);
  }

  // Validation methods
  validateLandingPage() {
    cy.url().should('include', '/explore/zenodo/');
    cy.url().should('include', '/landing/');
    this.getBreadcrumbs().should('be.visible');
    this.getBreadcrumbHome().should('contain', 'Home');
    this.getBreadcrumbActive().should('contain', 'Zenodo');
    this.getZenodoLogo().should('be.visible');
    this.getZenodoProjectLink().should('have.attr', 'href').and('include', 'zenodo:8080');
  }

  validateSearchForm() {
    this.getSearchForm().should('be.visible');
    this.getSearchInput().should('be.visible');
    this.getSearchInput().should('have.attr', 'placeholder');
    this.getSearchSubmitButton().should('be.visible');
    this.getServerSchemeField().should('exist');
    this.getServerPortField().should('exist');
  }

  validateNoResultsInitially() {
    this.getResultsTable().should('not.exist');
  }

  validateSearchResults() {
    this.getResultsTable().should('be.visible');
    this.getResultsTableRows().should('have.length.at.least', 1);
  }

  validatePagination() {
    this.getPaginationNav().should('be.visible');
    this.getNextPageLink().should('be.visible');
  }

  validateRecordPage() {
    this.getRecordActionsBar().should('be.visible');
    this.getRecordTitle().should('be.visible');
  }

  validateServerConfiguration() {
    this.getSearchForm().should('have.attr', 'action').and('include', 'zenodo');
    this.getServerSchemeField().should('have.value', 'http');
    this.getServerPortField().should('have.value', '8080');
  }
}

export default new Zenodo();