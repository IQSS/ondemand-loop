const selectors = {
  navProjectsLink: '#nav-projects',
  pageContainer: '[data-test-id="projects-page"]',
  actionsBar: '[data-test-id="project-actions-bar"]',
  createProjectButton: '[data-test-id="create-project-btn"]',
  projectList: '[data-test-id="project-list"]',
  projectSummaryItems: '#project-list [data-test-id="project-summary"]',
  projectName: '[data-test-id="project-name"]',
  emptyState: '[data-test-id="projects-empty-state"]',
  projectDeleteButton: 'button.project-delete-btn',
  deleteConfirmationModal: '#modal-delete-confirmation',
  modalConfirmButton: '[data-action="modal#confirm"]',
  flashDismissButton: '#flash-container button[data-bs-dismiss="alert"]',
};

export class ProjectIndexPage {
  visit() {
    cy.get(selectors.navProjectsLink).click();
  }

  getPageContainer() {
    return cy.get(selectors.pageContainer);
  }


  getActionsBar() {
    return cy.get(selectors.actionsBar);
  }

  clickCreateProject() {
    cy.get(selectors.createProjectButton).click();
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

  deleteProject(projectId) {
    // Click delete button for the project
    cy.get(`li#${projectId}`).within(() => {
      cy.get(selectors.projectDeleteButton).waitClick();
    });

    // Confirm deletion in the modal
    cy.get(selectors.deleteConfirmationModal).should('be.visible').within(() => {
      cy.get(selectors.modalConfirmButton).click();
    });

    // Wait for success message and dismiss it
    cy.get('#flash-container [role="alert"]').should('contain', 'deleted');
    cy.get(selectors.flashDismissButton).waitClick();

    cy.task('log', `Successfully deleted project: ${projectId}`);
  }
}

export default new ProjectIndexPage();
