import { visitLoopRoot, navigateToDataverse } from '../../plugins/navigation'

// Note: These tests use WireMock to mock the Dataverse Hub API (/api/installations)
// All mock installations have hostname set to http://dataverse:8080 to point to the mock server
// The mock data contains 50 dummy Dataverse installations for testing
describe('Browse Repositories - Dataverse', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('should navigate to Dataverse landing page via repositories menu', () => {
    // Use the existing navigation utility to access Dataverse
    navigateToDataverse()
    
    // Verify the page title is correct
    cy.title().should('eq', 'OnDemand Loop - Dataverse Landing page')
    
    // Verify the URL is correct
    cy.url().should('include', '/connect/dataverse/landing')
    
    // Verify breadcrumbs are present and correct
    cy.get('nav[aria-label="Breadcrumb"]').should('be.visible')
    cy.get('.breadcrumb .breadcrumb-item').first().should('contain', 'Home')
    cy.get('.breadcrumb .breadcrumb-item.active').should('contain', 'Dataverse')
    
    // Verify the Dataverse project logo is displayed
    cy.get('img[alt="Dataverse icon"]').should('be.visible')
    cy.get('a[aria-label="Visit the Dataverse project homepage"]').should('have.attr', 'href', 'https://dataverse.org/')
    
    cy.task('log', 'Successfully navigated to Dataverse landing page')
  })

  it('should validate Dataverse servers list is present and functional', () => {
    // Navigate to Dataverse landing page
    navigateToDataverse()
    
    // Verify search functionality exists
    cy.get('form input[name="query"]').should('be.visible')
    cy.get('form input[name="query"]').should('have.attr', 'placeholder', 'Search installations')
    cy.get('form input[value="Search"]').should('be.visible')
    
    // Verify results header is present (using mock data with 50 installations)
    cy.get('.card-header').contains('1 to 20 of 50 results').should('be.visible')
    
    // Verify pagination is present (with 50 mock installations, we should have 3 pages)
    cy.get('nav[aria-label="Landing page pagination"]').should('be.visible')
    cy.get('a[title="Next page"]').should('be.visible')
    
    // Verify server list is present with multiple entries
    cy.get('ul.list-group').should('be.visible')
    cy.get('li.list-group-item').should('have.length.at.least', 10)
    
    cy.task('log', 'Successfully validated Dataverse servers list')
  })

  it('should test search functionality for Dataverse installations', () => {
    // Navigate to Dataverse landing page
    navigateToDataverse()
    
    // Test search functionality (using mock data)
    cy.get('form input[name="query"]').type('Research')
    cy.get('form input[value="Search"]').click()
    
    // Verify search URL parameter
    cy.url().should('include', 'query=Research')
    
    // Verify search results are displayed
    cy.get('ul.list-group').should('be.visible')
    cy.get('li.list-group-item').should('exist')
    
    cy.task('log', 'Successfully tested Dataverse installation search')
  })

  it('should test pagination navigation in Dataverse landing page', () => {
    // Navigate to Dataverse landing page
    navigateToDataverse()
    
    // Verify we're on page 1 (using mock data with 50 installations)
    cy.get('.card-header').contains('1 to 20 of 50 results').should('be.visible')
    
    // Click next page
    cy.get('a[data-test="header-pagination-next"]').click()
    
    // Verify we're now on page 2 (with mock data: 21-40 of 50 results)
    cy.url().should('include', 'page=2')
    cy.get('ul.list-group').should('be.visible')
    cy.get('li.list-group-item').should('have.length.at.least', 1)
    
    cy.task('log', 'Successfully tested pagination in Dataverse landing page')
  })

  it('should test clicking on a Dataverse server to explore', () => {
    // Navigate to Dataverse landing page
    navigateToDataverse()
    
    // Click on the first Dataverse server (all mock installations point to http://dataverse:8080)
    cy.get('li.list-group-item a').first().click()
    
    // Verify navigation to the explore page
    cy.url().should('include', '/explore/dataverse/')
    cy.url().should('include', '/collections/')
    
    // Verify we're now on a Dataverse collection page
    cy.get('body').should('contain', 'Dataverse')
    
    cy.task('log', 'Successfully navigated from server list to explore page using mock data')
  })

  it('should validate repositories dropdown menu functionality', () => {
    // Verify repositories dropdown exists and is accessible
    cy.get('#repositoriesDropdown').should('be.visible')
    cy.get('#repositoriesDropdown').click()
    
    // Verify dropdown menu opens
    cy.get('#repositoriesMenu').should('be.visible')
    
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