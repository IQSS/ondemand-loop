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
    cy.get(selectors.navProjectsLink).waitClick();
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

  getProjectNameLink(projectId) {
    return cy.get(`${selectors.projectList} li#${projectId} a.project-name-link`);
  }

  getProjectNameById(projectId) {
    return this.getProjectSummaryById(projectId).find(selectors.projectName);
  }

  getEmptyState() {
    return cy.get(selectors.emptyState);
  }

  deleteProjects() {
    this.visit()
    this.getProjectList().then($list => {
      const projectIds = []
      $list.find('li').each((i, el) => {
        const id = Cypress.$(el).attr('id')
        if (id) {
          projectIds.push(id)
        }
      })

      if (projectIds.length > 0) {
        cy.task('log', `Deleting ${projectIds.length} projects`)
        projectIds.forEach(projectId => {
          this.deleteProject(projectId)
        })
      } else {
        cy.task('log', 'No projects to delete')
      }
    })
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
