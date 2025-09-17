const selectors = {
  // Navigation selectors
  repositoriesDropdown: '#repositoriesDropdown',
  dataverseNavItem: '#nav-dataverse',

  // Landing page selectors
  breadcrumbs: 'nav[aria-label="Breadcrumb"]',
  breadcrumbHome: '.breadcrumb .breadcrumb-item:first-child',
  breadcrumbActive: '.breadcrumb .breadcrumb-item.active',
  dataverseIcon: 'img[alt="Dataverse icon"]',
  dataverseProjectLink: 'a[aria-label="Visit the Dataverse project homepage"]',

  // Search functionality
  searchForm: 'form',
  searchInput: 'form input[name="query"]',
  searchSubmitButton: 'form input[value="Search"]',

  // Installation list
  installationsList: 'ul.list-group',
  installationItems: 'li.list-group-item',

  // Pagination
  resultsHeader: '.card-header',
  headerPaginationPrev: '[data-test="header-pagination-prev"]',
  headerPaginationNext: '[data-test="header-pagination-next"]',
  footerPaginationPrev: '[data-test="footer-pagination-prev"]',
  footerPaginationNext: '[data-test="footer-pagination-next"]',

  // Collection page selectors
  collectionActionsBar: '#dataverse-collection-action-bar',
  collectionTitle: '#dataverse-collection-action-bar h2',
  createBundleButton: 'button:contains("Create Collection Bundle")',
  openCollectionLink: 'a:contains("Open collection on Dataverse")',

  // Collection search
  collectionSearchInput: 'form input[name="query"]',
  collectionSearchButton: 'form input[value="Search Inside"]',

  // Results and items
  resultsList: 'ul.list-group',
  resultItems: 'li.list-group-item',
  noResultsAlert: '.alert.alert-warning',
};

export class Dataverse {
  // Navigation methods
  navigateToDataverse() {
    cy.get(selectors.repositoriesDropdown).click();
    cy.get(selectors.dataverseNavItem).click();
    cy.get('body').should('contain', 'Dataverse Landing');
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

  getDataverseIcon() {
    return cy.get(selectors.dataverseIcon);
  }

  getDataverseProjectLink() {
    return cy.get(selectors.dataverseProjectLink);
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

  searchInstallations(query) {
    this.getSearchInput().clear().type(query);
    this.getSearchSubmitButton().click();
  }

  // Installation list
  getInstallationsList() {
    return cy.get(selectors.installationsList);
  }

  getInstallationItems() {
    return cy.get(selectors.installationItems);
  }

  clickInstallationByIndex(index) {
    this.getInstallationItems().eq(index).find('a').click();
  }

  // Pagination
  getResultsHeader() {
    return cy.get(selectors.resultsHeader);
  }

  getHeaderPaginationNext() {
    return cy.get(selectors.headerPaginationNext);
  }

  getHeaderPaginationPrev() {
    return cy.get(selectors.headerPaginationPrev);
  }

  getFooterPaginationNext() {
    return cy.get(selectors.footerPaginationNext);
  }

  getFooterPaginationPrev() {
    return cy.get(selectors.footerPaginationPrev);
  }

  clickNextPage() {
    this.getHeaderPaginationNext().click();
  }

  clickPrevPage() {
    this.getHeaderPaginationPrev().click();
  }

  // Collection page methods
  getCollectionActionsBar() {
    return cy.get(selectors.collectionActionsBar);
  }

  getCollectionTitle() {
    return cy.get(selectors.collectionTitle);
  }

  getCreateBundleButton() {
    return cy.get(selectors.createBundleButton);
  }

  getOpenCollectionLink() {
    return cy.get(selectors.openCollectionLink);
  }

  clickCreateBundle() {
    this.getCreateBundleButton().click();
  }

  clickOpenCollection() {
    this.getOpenCollectionLink().click();
  }

  // Collection search
  getCollectionSearchInput() {
    return cy.get(selectors.collectionSearchInput);
  }

  getCollectionSearchButton() {
    return cy.get(selectors.collectionSearchButton);
  }

  searchInCollection(query) {
    this.getCollectionSearchInput().clear().type(query);
    this.getCollectionSearchButton().click();
  }

  // Results and validation
  getResultsList() {
    return cy.get(selectors.resultsList);
  }

  getResultItems() {
    return cy.get(selectors.resultItems);
  }

  getNoResultsAlert() {
    return cy.get(selectors.noResultsAlert);
  }

  // Validation methods
  validateLandingPage() {
    cy.title().should('eq', 'OnDemand Loop - Dataverse Landing page');
    cy.url().should('include', '/connect/dataverse/landing');
    this.getBreadcrumbs().should('be.visible');
    this.getBreadcrumbHome().should('contain', 'Home');
    this.getBreadcrumbActive().should('contain', 'Dataverse');
    this.getDataverseIcon().should('be.visible');
    this.getDataverseProjectLink().should('have.attr', 'href', 'https://dataverse.org/');
  }

  validateSearchFunctionality() {
    this.getSearchInput().should('be.visible');
    this.getSearchInput().should('have.attr', 'placeholder', 'Search installations');
    this.getSearchSubmitButton().should('be.visible');
  }

  validateInstallationsList() {
    this.getInstallationsList().should('be.visible');
    this.getInstallationItems().should('have.length.at.least', 1);
  }

  validatePagination() {
    this.getResultsHeader().should('be.visible');
    this.getHeaderPaginationNext().should('be.visible');
  }

  validateCollectionPage() {
    this.getCollectionActionsBar().should('be.visible');
    this.getCreateBundleButton().should('be.visible');
    this.getOpenCollectionLink().should('be.visible');
  }
}

export default new Dataverse();