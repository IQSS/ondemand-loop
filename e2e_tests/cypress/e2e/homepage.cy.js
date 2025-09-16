import { visitLoopRoot } from '../plugins/navigation'
import homePage from '../pages/HomePage'

describe('Home page', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('shows welcome and beta notices', () => {
    homePage.visit()
    homePage.getWelcomeMessage().should('be.visible')
    homePage.getBetaMessage().should('be.visible')
    homePage.getGuideLink().should('have.attr', 'href')
    homePage.getCreateProjectForm().should('exist')
    homePage.getBetaFeedbackLink().should('have.attr', 'href')

    cy.task('log', 'Test completed successfully using cy.loop configuration')
  })
})
