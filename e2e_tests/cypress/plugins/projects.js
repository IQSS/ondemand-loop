import { navigateToProjects } from './navigation'

export const deleteProject = (projectId) => {
  // Navigate to projects page
  navigateToProjects()
  
  // Find the project by ID and click delete button
  cy.get(`li#${projectId}`).within(() => {
    cy.get('button.project-delete-btn').click()
  })

  // Confirm deletion in the modal
  cy.get('#modal-delete-confirmation').should('be.visible').within(() => {
    cy.get('[data-action="modal#confirm"]').click()
  })

  // Wait for success message
  cy.get('#flash-container [role="alert"]').should('contain', 'deleted')
  
  cy.task('log', `Successfully cleaned up project: ${projectId}`)
}

export const deleteAllProjects = () => {
  // Navigate to projects page
  navigateToProjects()
  
  // Get all project list items and delete them one by one
  cy.get('body').then($body => {
    if ($body.find('.list-group .list-group-item').length > 0) {
      cy.get('.list-group .list-group-item').each($el => {
        const projectId = $el.attr('id')
        if (projectId) {
          // Click delete button for this project
          cy.wrap($el).within(() => {
            cy.get('button.project-delete-btn').click()
          })
          
          // Confirm deletion in the modal
          cy.get('#modal-delete-confirmation').should('be.visible').within(() => {
            cy.get('[data-action="modal#confirm"]').click()
          })
          
          // Wait for success message
          cy.get('#flash-container [role="alert"]').should('contain', 'deleted')
          
          cy.task('log', `Cleaned up project: ${projectId}`)
        }
      })
    }
  })
  
  cy.task('log', 'Successfully cleaned up all projects')
}