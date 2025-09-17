const selectors = {
  breadcrumbs: 'nav[aria-label="Breadcrumb"]',
};

export class PageBreadcrumbs {
  getBreadcrumbs() {
    return cy.get(selectors.breadcrumbs);
  }
}

export default new PageBreadcrumbs();