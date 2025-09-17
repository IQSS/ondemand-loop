const selectors = {
  appActionsBar: '#app-actions-bar',
  projectDropdown: '#repo_resolver_project_dropdown',
  projectDropdownMenu: 'ul.dropdown-menu',
  projectDropdownItem: (projectId) => `a[data-project-id="${projectId}"]`,
  openProjectLink: '[data-controller="select-project-listener"] .btn-outline-dark',
  createProjectButton: '#app-bar-create-project-btn',
  exploreRepoForm: '#app-actions-bar .explore-repo',
  exploreRepoInput: '#explore-repo-url-input',
  exploreSubmitButton: '#explore-repo-url-submit',
  repositoryActivityButton: '[data-modal-url-value*="repository_activity"]',
  projectDisplayLabel: '[data-select-project-target="displayLabel"]',
  loadingSpinner: '[data-select-project-target="spinner"]',
};

export class AppActionsBar {
  getAppActionsBar() {
    return cy.get(selectors.appActionsBar);
  }

  getProjectDropdown() {
    return cy.get(selectors.projectDropdown);
  }

  clickProjectDropdown() {
    this.getProjectDropdown().click();
  }

  getProjectDropdownMenu() {
    return cy.get(selectors.projectDropdownMenu);
  }

  selectProject(projectId) {
    this.clickProjectDropdown();
    cy.get(selectors.projectDropdownItem(projectId)).click();
  }

  getSelectedProjectLabel() {
    return cy.get(selectors.projectDisplayLabel);
  }

  clickOpenProject() {
    cy.get(selectors.openProjectLink).click();
  }

  clickCreateProject() {
    cy.get(selectors.createProjectButton).click();
  }

  getExploreRepoForm() {
    return cy.get(selectors.exploreRepoForm);
  }

  getExploreRepoInput() {
    return cy.get(selectors.exploreRepoInput);
  }

  typeRepoUrl(url) {
    this.getExploreRepoInput().clear().type(url);
  }

  getExploreSubmitButton() {
    return cy.get(selectors.exploreSubmitButton);
  }

  clickExploreSubmit() {
    cy.get(selectors.exploreSubmitButton).click();
  }

  exploreRepository(url) {
    this.typeRepoUrl(url);
    this.clickExploreSubmit();
  }

  clickRepositoryActivity() {
    cy.get(selectors.repositoryActivityButton).click();
  }

  waitForProjectSelection() {
    cy.get(selectors.loadingSpinner).should('not.be.visible');
  }
}

export default new AppActionsBar();