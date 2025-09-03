import { navigateToProjects } from './navigation'

export const cleanProject = (projectId) => {
  // Navigate to projects page
  navigateToProjects()
  
  // Find the project by ID and click delete button
  cy.get(`li#${projectId}`).within(() => {
    cy.get('button[title*="Delete"], button[aria-label*="delete"], .btn-outline-dark.icon-hover-danger').click()
  })
  
  // Confirm deletion in the modal
  cy.get('#modal-delete-confirmation .btn-danger, .modal .btn-danger').click()
  
  // Verify delete success message
  cy.get('.alert-success, .alert.alert-success, [role="alert"]').should('contain', 'deleted')
  
  cy.task('log', `Successfully cleaned up project: ${projectId}`)
}

export const cleanAllProjects = () => {
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
            cy.get('button[title*="Delete"], button[aria-label*="delete"], .btn-outline-dark.icon-hover-danger').click()
          })
          
          // Confirm deletion in the modal
          cy.get('#modal-delete-confirmation .btn-danger, .modal .btn-danger').click()
          
          // Wait for success message
          cy.get('.alert-success, .alert.alert-success, [role="alert"]').should('contain', 'deleted')
          
          cy.task('log', `Cleaned up project: ${projectId}`)
        }
      })
    }
  })
  
  cy.task('log', 'Successfully cleaned up all projects')
}