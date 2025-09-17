import homePage from '../../pages/HomePage'
import dataverse from '../../pages/connectors/Dataverse'

// Note: These tests use WireMock to mock the Dataverse Hub API (/api/installations)
// All mock installations have hostname set to http://dataverse:8080 to point to the mock server
// The mock data contains 50 dummy Dataverse installations for testing
describe('Browse Repositories - Dataverse', () => {
  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  it('should navigate to Dataverse landing page via repositories menu', () => {
    // Navigate to Dataverse using the connector page object
    dataverse.navigateToDataverse()

    // Validate the landing page using the page object
    dataverse.validateLandingPage()

    cy.task('log', 'Successfully navigated to Dataverse landing page')
  })

  it('should validate Dataverse servers list is present and functional', () => {
    // Navigate to Dataverse landing page
    dataverse.navigateToDataverse()

    // Validate search functionality
    dataverse.validateSearchFunctionality()

    // Verify results header is present (using mock data with 50 installations)
    dataverse.getResultsHeader().contains('1 to 20 of 50 results').should('be.visible')

    // Validate pagination
    dataverse.validatePagination()

    // Validate installations list
    dataverse.validateInstallationsList()
    dataverse.getInstallationItems().should('have.length.at.least', 10)

    cy.task('log', 'Successfully validated Dataverse servers list')
  })

  it('should test search functionality for Dataverse installations', () => {
    // Navigate to Dataverse landing page
    dataverse.navigateToDataverse()

    // Test search functionality using page object
    dataverse.searchInstallations('Research')

    // Verify search URL parameter
    cy.url().should('include', 'query=Research')

    // Verify search results are displayed
    dataverse.getInstallationsList().should('be.visible')
    dataverse.getInstallationItems().should('exist')

    cy.task('log', 'Successfully tested Dataverse installation search')
  })

  it('should test pagination navigation in Dataverse landing page', () => {
    // Navigate to Dataverse landing page
    dataverse.navigateToDataverse()

    // Verify we're on page 1 (using mock data with 50 installations)
    dataverse.getResultsHeader().contains('1 to 20 of 50 results').should('be.visible')

    // Click next page using page object
    dataverse.clickNextPage()

    // Verify we're now on page 2 (with mock data: 21-40 of 50 results)
    cy.url().should('include', 'page=2')
    dataverse.getInstallationsList().should('be.visible')
    dataverse.getInstallationItems().should('have.length.at.least', 1)

    cy.task('log', 'Successfully tested pagination in Dataverse landing page')
  })

  it('should test clicking on a Dataverse server to explore', () => {
    // Navigate to Dataverse landing page
    dataverse.navigateToDataverse()

    // Click on the first Dataverse server using page object
    dataverse.clickInstallationByIndex(0)

    // Verify navigation to the explore page
    cy.url().should('include', '/explore/dataverse/')
    cy.url().should('include', '/collections/')

    // Verify we're now on a Dataverse collection page
    cy.get('body').should('contain', 'Dataverse')

    cy.task('log', 'Successfully navigated from server list to explore page using mock data')
  })

  it('should validate repositories dropdown menu functionality', () => {
    // Verify repositories dropdown exists and is accessible
    cy.get('#repositories-dropdown').should('be.visible')
    cy.get('#repositories-dropdown').click()
    
    // Verify dropdown menu opens
    cy.get('#repositories-menu').should('be.visible')
    
    // Verify Dataverse option exists with proper icon
    cy.get('#nav-dataverse').should('be.visible')
    cy.get('#nav-dataverse img[alt="dataverse"]').should('be.visible')
    cy.get('#nav-dataverse').should('contain', 'Dataverse')
    
    // Verify Zenodo option exists
    cy.get('#nav-zenodo').should('be.visible')
    cy.get('#nav-zenodo img[alt="zenodo"]').should('be.visible')
    cy.get('#nav-zenodo').should('contain', 'Zenodo')
    
    // Verify Settings option exists
    cy.get('#nav-repo-settings').should('be.visible')
    cy.get('#nav-repo-settings').should('contain', 'Settings')
    
    cy.task('log', 'Successfully validated repositories dropdown menu')
  })
})