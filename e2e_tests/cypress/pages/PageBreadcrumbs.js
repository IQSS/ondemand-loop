const selectors = {
  breadcrumbs: 'nav[data-test-id="breadcrumbs"]',
  breadcrumbHome: '.breadcrumb .breadcrumb-item:first-child',
  breadcrumbActive: '.breadcrumb .breadcrumb-item.active',
};

export class PageBreadcrumbs {
  getBreadcrumbs() {
    return cy.get(selectors.breadcrumbs);
  }

  getBreadcrumbHome() {
    return cy.get(selectors.breadcrumbHome);
  }

  getBreadcrumbActive() {
    return cy.get(selectors.breadcrumbActive);
  }
}

export default new PageBreadcrumbs();