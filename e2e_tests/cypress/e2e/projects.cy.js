import { visitLoopRoot, navigateToProjects } from '../plugins/navigation'
import { deleteProject } from '../plugins/projects'

describe('Projects', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('should create a new project from the project actions bar', () => {
    // Navigate to projects page
    navigateToProjects()
    
    // Click create project button
    cy.get('#create-project-btn').click()
    
    // Assert success message appears
    cy.get('#flash-container [role="alert"]').should('contain', 'created')
    
    // Assert we're on the project details page
    cy.url().should('include', '/projects/')
    cy.title().should('match', /project details/i)
    
    // Assert project name is visible on the page
    cy.get('#project-name').should('be.visible')
    cy.get('#project-name').should('not.be.empty')
    
    cy.task('log', 'Successfully created project and navigated to details page')
    
    // Cleanup
    cy.get('[data-project-id]').invoke('attr', 'data-project-id').then(projectId => {
      deleteProject(projectId)
    })
  })

  it('should create a new project from the app actions bar', () => {
    // Navigate to projects page
    navigateToProjects()
    
    // Click create project button from the app actions bar
    cy.get('#app-bar-create-project-btn').click()
    
    // Assert success message appears
    cy.get('#flash-container [role="alert"]').should('contain', 'created')
    
    // Assert we're on the project details page
    cy.url().should('include', '/projects/')
    cy.title().should('match', /project details/i)
    
    // Assert project name is visible on the page
    cy.get('#project-name').should('be.visible')
    cy.get('#project-name').should('not.be.empty')
    
    cy.task('log', 'Successfully created project from app actions bar')
    
    // Cleanup
    cy.get('[data-project-id]').invoke('attr', 'data-project-id').then(projectId => {
      deleteProject(projectId)
    })
  })

  it('should edit project name', () => {
    // Navigate to projects page and create a project
    navigateToProjects()
    cy.get('#create-project-btn').click()
    
    // Get the created project ID
    cy.get('[data-project-id]').invoke('attr', 'data-project-id').as('projectId')

    // Click edit project name button
    cy.get('#edit-project-name-btn').click()
    
    // Clear input and add new name
    const newName = 'Updated Project Name'
    cy.get('#edit-name-input').clear().type(newName)
    
    // Click save
    cy.get('#save-name-btn').click()
    
    // Verify the name has been updated in the H tag
    cy.get('#project-name').should('contain', newName)
    
    // Navigate to the projects page
    navigateToProjects()
    
    // Verify that the specific project shows the new name using project ID
    cy.get('@projectId').then(projectId => {
      cy.get(`li#${projectId} [data-test="project-name"]`).should('have.text', newName)
      
      // Cleanup
      deleteProject(projectId)
    })
    
    cy.task('log', 'Successfully edited project name')
  })
})