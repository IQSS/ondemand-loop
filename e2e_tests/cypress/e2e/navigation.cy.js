import { 
  visitLoopRoot, 
  navigateToProjects, 
  navigateToDownloads, 
  navigateToUploads,
  navigateToRepositorySettings,
  navigateToDataverse,
  navigateToZenodo,
  navigateToHome
} from '../plugins/navigation'

describe('Navigation', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('should navigate to Projects page', () => {
    navigateToProjects()
    cy.task('log', 'Successfully navigated to Projects page')
  })

  it('should navigate to Downloads page', () => {
    navigateToDownloads()
    cy.task('log', 'Successfully navigated to Downloads page')
  })

  it('should navigate to Uploads page', () => {
    navigateToUploads()
    cy.task('log', 'Successfully navigated to Uploads page')
  })

  it('should navigate to Dataverse explore page', () => {
    navigateToDataverse()
    cy.task('log', 'Successfully navigated to Dataverse explore page')
  })

  it('should navigate to Zenodo explore page', () => {
    navigateToZenodo()
    cy.task('log', 'Successfully navigated to Zenodo explore page')
  })

  it('should navigate to Repository Settings page', () => {
    navigateToRepositorySettings()
    cy.task('log', 'Successfully navigated to Repository Settings page')
  })

  it('should navigate to Home page via logo link', () => {
    // First navigate away from home
    navigateToProjects()
    
    // Then navigate back home using logo
    navigateToHome()
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
})