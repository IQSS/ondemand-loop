const selectors = {
  navProjectsLink: '#nav-projects',
  pageContainer: '#projects-page',
  breadcrumbs: 'nav[aria-label="Breadcrumb"]',
  actionsBar: '#project-actions-bar',
  createProjectButton: '#create-project-btn',
  appBarCreateProjectButton: '#app-bar-create-project-btn',
  projectList: '#project-list',
  projectSummaryItems: '#project-list [data-test="project-summary"]',
  projectName: '[data-test="project-name"]',
  emptyState: '#projects-empty-state',
  flashAlert: '#flash-container [role="alert"]',
};

export class ProjectIndexPage {
  visit() {
    cy.get(selectors.navProjectsLink).click();
  }

  getPageContainer() {
    return cy.get(selectors.pageContainer);
  }

  getBreadcrumbs() {
    return cy.get(selectors.breadcrumbs);
  }

  getActionsBar() {
    return cy.get(selectors.actionsBar);
  }

  clickCreateProject() {
    cy.get(selectors.createProjectButton).click();
  }

  clickAppBarCreateProject() {
    cy.get(selectors.appBarCreateProjectButton).click();
  }

  getFlashAlert() {
    return cy.get(selectors.flashAlert);
  }

  getProjectList() {
    return cy.get(selectors.projectList);
  }

  getProjectSummaries() {
    return cy.get(selectors.projectSummaryItems);
  }

  getProjectSummaryById(projectId) {
    return cy.get(`${selectors.projectList} li#${projectId}`);
  }

  getProjectNameById(projectId) {
    return this.getProjectSummaryById(projectId).find(selectors.projectName);
  }

  getEmptyState() {
    return cy.get(selectors.emptyState);
  }
}

export default new ProjectIndexPage();
