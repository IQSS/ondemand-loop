import projectIndexPage from '../pages/ProjectIndexPage'
import projectDetailsPage from '../pages/ProjectDetailsPage'
import flashMessageComponent from '../pages/FlashMessageComponent'
import homePage from '../pages/HomePage'

const confirmProjectVisibleOnIndex = () => {
  return cy
    .get('[data-project-id]')
    .invoke('attr', 'data-project-id')
    .then(projectId => {
      return cy.get('#project-name').invoke('text').then(projectName => {
        const trimmedName = projectName.trim()

        projectIndexPage.visit()
        projectIndexPage.getPageContainer().should('be.visible')
        projectIndexPage.getProjectSummaryById(projectId).should('exist')
        projectIndexPage.getProjectNameById(projectId).should('contain', trimmedName)

        projectIndexPage.deleteProject(projectId)
        cy.task('log', `Verified project ${projectId} appears on index and cleaned up`)
      })
    })
}

describe('Project Index', () => {
  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  it('creates a new project from the project actions bar', () => {
    projectIndexPage.visit()
    projectIndexPage.getPageContainer().should('be.visible')
    projectIndexPage.getActionsBar().should('be.visible')

    projectIndexPage.clickCreateProject()
    projectDetailsPage.assertInProjectDetails()
    flashMessageComponent.getFlashAlert().should('contain', 'created')

    return confirmProjectVisibleOnIndex()
  })

  it('should edit project name', () => {
    projectIndexPage.visit()
    projectIndexPage.getPageContainer().should('be.visible')

    projectIndexPage.clickCreateProject()
    projectDetailsPage.assertInProjectDetails()

    // Get the created project ID
    cy.get('[data-project-id]').invoke('attr', 'data-project-id').as('projectId')

    // Click edit project name button
    projectDetailsPage.waitClickEditProjectName()

    // Clear input and add new name
    const newName = 'Updated Project Name'
    projectDetailsPage.typeProjectName(newName)

    // Click save
    projectDetailsPage.clickSaveName()

    // Verify the name has been updated in the H tag
    projectDetailsPage.getProjectName().should('contain', newName)

    // Navigate to the projects page
    projectIndexPage.visit()

    // Verify that the specific project shows the new name using project ID
    cy.get('@projectId').then(projectId => {
      projectIndexPage.getProjectNameById(projectId).should('have.text', newName)

      // Cleanup
      projectIndexPage.deleteProject(projectId)
    })

    cy.task('log', 'Successfully edited project name')
  })
})
