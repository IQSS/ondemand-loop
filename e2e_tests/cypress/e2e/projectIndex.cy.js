import { visitLoopRoot } from '../plugins/navigation'
import { deleteProject } from '../plugins/projects'
import projectIndexPage from '../pages/ProjectIndexPage'

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

        deleteProject(projectId)
        cy.task('log', `Verified project ${projectId} appears on index and cleaned up`)
      })
    })
}

describe('Project Index', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('creates a new project from the project actions bar', () => {
    projectIndexPage.visit()
    projectIndexPage.getPageContainer().should('be.visible')
    projectIndexPage.getActionsBar().should('be.visible')

    projectIndexPage.clickCreateProject()
    projectIndexPage.getFlashAlert().should('contain', 'created')

    return confirmProjectVisibleOnIndex()
  })

  it('creates a new project from the app actions bar', () => {
    projectIndexPage.visit()
    projectIndexPage.getPageContainer().should('be.visible')

    projectIndexPage.clickAppBarCreateProject()
    projectIndexPage.getFlashAlert().should('contain', 'created')

    return confirmProjectVisibleOnIndex()
  })
})
