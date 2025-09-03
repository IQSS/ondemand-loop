import { navigateToProjects } from './navigation'

const performProjectDeletion = (projectId) => {
  // Click delete button for the project
  cy.get(`li#${projectId}`).within(() => {
    cy.get('button.project-delete-btn').waitClick()
  })

  // Confirm deletion in the modal
  cy.get('#modal-delete-confirmation').should('be.visible').within(() => {
    cy.get('[data-action="modal#confirm"]').click()
  })

  // Wait for success message
  cy.get('#flash-container [role="alert"]').should('contain', 'deleted')
  cy.get('#flash-container button[data-bs-dismiss="alert"]').waitClick()

  cy.task('log', `Successfully deleted project: ${projectId}`)
}

export const deleteProject = (projectId) => {
  // Navigate to projects page
  navigateToProjects()
  // Perform deletion
  performProjectDeletion(projectId)
}

export const deleteAllProjects = () => {
  // Navigate to projects page
  navigateToProjects()
  
  // Delete all projects
  cy.get('body').then(($body) => {
    if ($body.find('[data-test="project-summary"]').length) {
      let deletedCount = 0
      cy.get('[data-test="project-summary"]').each(($project) => {
        const projectId = $project.attr('id')
        performProjectDeletion(projectId)
        deletedCount++
      }).then(() => {
        cy.task('log', `Successfully deleted ${deletedCount} projects`)
      })
    }
  })
}