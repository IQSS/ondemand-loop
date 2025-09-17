import homePage from '../pages/HomePage'
import projectIndexPage from '../pages/ProjectIndexPage'
import downloadsPage from '../pages/DownloadsPage'
import uploadsPage from '../pages/UploadsPage'
import dataverse from '../pages/connectors/Dataverse'
import zenodo from '../pages/connectors/Zenodo'
import repositorySettingsPage from '../pages/RepositorySettingsPage'

describe('Navigation', () => {
  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  it('should navigate to Projects page', () => {
    projectIndexPage.visit()
    cy.task('log', 'Successfully navigated to Projects page')
  })

  it('should navigate to Downloads page', () => {
    downloadsPage.visit()
    cy.task('log', 'Successfully navigated to Downloads page')
  })

  it('should navigate to Uploads page', () => {
    uploadsPage.visit()
    cy.task('log', 'Successfully navigated to Uploads page')
  })

  it('should navigate to Dataverse explore page', () => {
    dataverse.navigateToDataverse()
    cy.task('log', 'Successfully navigated to Dataverse explore page')
  })

  it('should navigate to Zenodo explore page', () => {
    zenodo.navigateToZenodo()
    cy.task('log', 'Successfully navigated to Zenodo explore page')
  })

  it('should navigate to Repository Settings page', () => {
    repositorySettingsPage.visit()
    cy.task('log', 'Successfully navigated to Repository Settings page')
  })

  it('should navigate to Home page via logo link', () => {
    // First navigate away from home
    projectIndexPage.visit()
    
    // Then navigate back home using logo
    homePage.visit()
    cy.task('log', 'Successfully navigated to Home page via logo')
  })

  it('should verify navigation menu is present and contains expected links', () => {
    cy.get('nav').should('be.visible')
    cy.get('nav').contains('Projects').should('be.visible')
    cy.get('nav').contains('Downloads').should('be.visible')
    cy.get('nav').contains('Uploads').should('be.visible')
    cy.get('nav').contains('Repositories').should('be.visible')

    // Verify logo link exists
    cy.get('nav #logo-link').should('exist')
    
    cy.task('log', 'Navigation menu contains all expected links')
  })

  it('should verify right-hand side navigation URLs', () => {
    // Verify Open OnDemand link URL
    cy.get('nav a').contains('Open OnDemand').should('have.attr', 'href', Cypress.env('dashboardPath'))
    
    // Open Help dropdown and verify links
    cy.get('#help-dropdown').click()
    
    // Verify Guide link has target="_blank"
    cy.get('#help-menu a').contains('Guide').should('have.attr', 'target', '_blank')

    // Verify Sitemap link
    cy.get('#help-menu a').contains('Sitemap').should('exist')

    // Verify Restart link exists
    cy.get('#help-menu a').contains('Restart').should('exist')
    
    // Verify Reset form exists
    cy.get('#help-menu form').contains('Reset App')
    
    cy.task('log', 'Right-hand side navigation URLs verified')
  })

})