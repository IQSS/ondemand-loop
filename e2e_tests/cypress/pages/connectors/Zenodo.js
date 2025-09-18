import pageBreadcrumbs from '../PageBreadcrumbs';

const selectors = {
  // Navigation selectors
  repositoriesDropdown: '#repositories-dropdown',
  zenodoNavItem: '#nav-zenodo',

  // Landing page selectors
  zenodoLogoContainer: 'div[data-test-id="zenodo-logo-container"]',
  zenodoLogo: 'div[data-test-id="zenodo-logo-container"] img',
  zenodoProjectLink: 'div[data-test-id="zenodo-logo-container"] a',

  // Search functionality
  searchForm: '#zenodo-search-form',
  searchInput: '[data-test-id="zenodo-search-input"]',
  searchSubmitButton: '[data-test-id="zenodo-search-submit"]',
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
  paginationNav: 'nav[data-test-id="header-pagination"]',
  nextPageLink: '[data-test-id="header-pagination-next"], [data-test-id="footer-pagination-next"]',
  prevPageLink: '[data-test-id="header-pagination-prev"], [data-test-id="footer-pagination-prev"]',

  // Record page selectors
  recordActionsBar: '[data-test-id="record-actions-bar"]',
  recordTitle: '[data-test-id="record-title"]',
  createBundleButton: '[data-test-id="create-bundle-btn"]',
  openRecordLink: '[data-test-id="open-record-link"]',

  // Record files
  recordFiles: '[data-test-id="record-files"]',
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
    pageBreadcrumbs.getBreadcrumbs().should('be.visible');
    pageBreadcrumbs.getBreadcrumbHome().should('contain', 'Home');
    pageBreadcrumbs.getBreadcrumbActive().should('contain', 'Zenodo');
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