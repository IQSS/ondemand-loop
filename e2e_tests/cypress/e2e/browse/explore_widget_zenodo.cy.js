import appActionsBar from '../../pages/AppActionsBar'
import homePage from '../../pages/HomePage'

// Note: These tests use WireMock to mock the Zenodo API running at http://zenodo:8080
// The mock server contains 2 dummy records for search and pagination testing
// Mock behavior: any search returns "Record One" and "Record Two" with basic metadata
describe('Explore Widget - Zenodo', () => {
  const ZENODO_URL = 'http://zenodo:8080'

  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  it('should navigate to explore Zenodo page and verify rendering', () => {
    // Navigate to the homepage first
    homePage.visitLoopRoot()

    // Find and interact with the explore widget input
    appActionsBar.getExploreRepoInput().should('be.visible')

    // Enter the Zenodo URL (pointing to mock server)
    appActionsBar.exploreRepository(ZENODO_URL)
    
    // Verify that we're on the explore page and it rendered successfully
    cy.url().should('include', '/explore/')
    cy.url().should('include', 'zenodo')
    
    // Verify the page title is correct
    cy.title().should('eq', 'OnDemand Loop - Zenodo')
    
    // Verify breadcrumbs are present and structured correctly
    cy.get('nav[aria-label="Breadcrumb"]').should('be.visible')
    cy.get('.breadcrumb').should('be.visible')
    cy.get('.breadcrumb .breadcrumb-item').should('have.length.at.least', 2)
    
    // Verify specific breadcrumb items
    cy.get('.breadcrumb .breadcrumb-item').first().should('contain', 'Home')
    cy.get('.breadcrumb .breadcrumb-item.active').should('contain', 'Zenodo')
    
    // Verify the Zenodo logo container is present
    cy.get('div[data-test="zenodo-logo-container"]').should('be.visible')
    cy.get('div[data-test="zenodo-logo-container"] img').should('be.visible')
    
    // Verify the search form is present and functional
    cy.get('form input[name="query"]').should('be.visible')
    cy.get('form input[name="query"]').should('have.attr', 'placeholder')
    cy.get('form input[type="submit"]').should('be.visible')
    
    cy.task('log', 'Successfully navigated to Zenodo explore page via widget and verified rendering')
  })

  it('should handle explore widget with zenodo URL via explore button', () => {
    // Navigate to the homepage
    homePage.visitLoopRoot()

    // Find the explore widget
    appActionsBar.getExploreRepoInput().should('be.visible')

    // Enter the Zenodo URL and submit via explore button
    appActionsBar.exploreRepository(ZENODO_URL)
    
    // Verify navigation to explore page
    cy.url().should('include', '/explore/')
    cy.url().should('include', 'zenodo')
    
    // Verify page loads successfully
    cy.get('body').should('contain', 'Zenodo')
    
    cy.task('log', 'Successfully explored Zenodo via explore button with mock server')
  })

  it('should validate explore widget is present on homepage', () => {
    // Verify the explore widget exists and is properly structured
    appActionsBar.getExploreRepoForm().should('be.visible')
    appActionsBar.getExploreRepoInput().should('be.visible')
    appActionsBar.getExploreRepoInput().should('have.attr', 'placeholder')
    appActionsBar.getExploreSubmitButton().should('be.visible')

    cy.task('log', 'Explore widget validation completed for Zenodo')
  })

  it('should test search functionality within zenodo repository', () => {
    // Navigate to zenodo repository first via explore widget
    appActionsBar.exploreRepository(ZENODO_URL)
    
    // Wait for page to load and verify we're on the Zenodo landing page
    cy.get('div[data-test="zenodo-logo-container"]').should('be.visible')
    
    // Test search functionality (any search returns mock data with 2 records)
    cy.get('form input[name="query"]').type('Record')
    cy.get('form input[type="submit"]').click()
    
    // Verify search results are displayed (mock returns 2 records)
    cy.url().should('include', 'query=Record')
    cy.get('table.table-striped').should('be.visible')
    cy.get('table tbody tr').should('have.length', 2)
    
    // Verify search results contain expected mock data
    cy.get('table tbody tr').first().should('contain', 'Record One')
    cy.get('table tbody tr').last().should('contain', 'Record Two')
    
    cy.task('log', 'Successfully tested search functionality within Zenodo repository using mock data')
  })

  it('should test record navigation from search results', () => {
    // Navigate to zenodo repository and perform search
    appActionsBar.exploreRepository(ZENODO_URL)
    
    // Perform search to get results
    cy.get('form input[name="query"]').type('Record')
    cy.get('form input[type="submit"]').click()
    
    // Verify search results table
    cy.get('table tbody tr').should('have.length', 2)
    
    // Click on first record link
    cy.get('table tbody tr').first().find('td a').click()
    
    // Verify navigation to record page
    cy.url().should('include', '/explore/zenodo/')
    cy.url().should('include', '/records/')
    
    // Verify we're on a record detail page
    cy.get('body').should('contain', 'Record')
    
    cy.task('log', 'Successfully tested record navigation from search results using mock data')
  })

  it('should handle different zenodo URL formats', () => {
    // Test with different URL variations that should all point to mock server
    const zenodoUrls = [
      'http://zenodo:8080',
      'http://zenodo:8080/',
    ]

    zenodoUrls.forEach((url, index) => {
      // Navigate to homepage
      homePage.visitLoopRoot()
      
      // Enter the URL and submit
      appActionsBar.exploreRepository(url)
      
      // Verify navigation works
      cy.url().should('include', '/explore/')
      cy.url().should('include', 'zenodo')
      
      // Verify page loads
      cy.get('div[data-test="zenodo-logo-container"]').should('be.visible')
      
      cy.task('log', `Successfully tested Zenodo URL format ${index + 1}: ${url}`)
    })
  })

  it('should verify zenodo server configuration in search form', () => {
    // Navigate to zenodo explore page
    appActionsBar.exploreRepository(ZENODO_URL)
    
    // Verify hidden server configuration fields point to mock server
    cy.get('#zenodo-search-form').should('have.attr', 'action').and('include', 'zenodo')
    cy.get('#zenodo-search-form input[name="server_scheme"]').should('have.value', 'http')
    cy.get('#zenodo-search-form input[name="server_port"]').should('have.value', '8080')

    cy.task('log', 'Successfully verified Zenodo server configuration points to mock server')
  })
})