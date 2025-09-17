import appActionsBar from '../pages/AppActionsBar'
import projectDetailsPage from '../pages/ProjectDetailsPage'
import flashMessageComponent from '../pages/FlashMessageComponent'
import homePage from '../pages/HomePage'
import projectIndexPage from '../pages/ProjectIndexPage'

describe('Application Actions Bar', () => {
    beforeEach(() => {
        homePage.visitLoopRoot()
    })

    it('should create a new project from the application actions bar', () => {
        // Navigate to projects page
        projectIndexPage.visit()

        // Click create project button from the app actions bar
        appActionsBar.clickCreateProject()

        // Assert success message appears
        flashMessageComponent.getFlashAlert().should('contain', 'created')

        // Assert we're on the project details page
        projectDetailsPage.assertInProjectDetails()

        // Assert project name is visible on the page
        projectDetailsPage.getProjectName().should('be.visible')
        projectDetailsPage.getProjectName().should('not.be.empty')

        cy.task('log', 'Successfully created project from app actions bar')

        // Cleanup
        cy.get('[data-project-id]').invoke('attr', 'data-project-id').then(projectId => {
            projectIndexPage.visit()
            projectIndexPage.deleteProject(projectId)
        })
    })

})