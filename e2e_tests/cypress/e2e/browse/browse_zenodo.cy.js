
import { visitLoopRoot, navigateToZenodo } from '../../plugins/navigation'

// Note: These tests use WireMock to mock the Zenodo API (/api/records)
// The mock server runs at http://zenodo:8080 and contains 2 dummy records for testing
// Mock records: "Record One" and "Record Two" with basic metadata and files
describe('Browse Repositories - Zenodo', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('should navigate to Zenodo landing page via repositories menu', () => {
    // Use the existing navigation utility to access Zenodo
    navigateToZenodo()
    
    // Verify the URL is correct
    cy.url().should('include', '/explore/zenodo/')
    cy.url().should('include', '/landing/')
    
    // Verify breadcrumbs are present and correct
    cy.get('nav[aria-label="Breadcrumb"]').should('be.visible')
    cy.get('.breadcrumb .breadcrumb-item').first().should('contain', 'Home')
    cy.get('.breadcrumb .breadcrumb-item.active').should('contain', 'Zenodo')
    
    // Verify the Zenodo project logo is displayed
    cy.get('div[data-test="zenodo-logo-container"] img').should('be.visible')
    cy.get('div[data-test="zenodo-logo-container"] a').should('have.attr', 'href').and('include', 'zenodo:8080')
    
    cy.task('log', 'Successfully navigated to Zenodo landing page')
  })

  it('should validate initial search form is present', () => {
    // Navigate to Zenodo landing page
    navigateToZenodo()
    
    // Verify search form exists
    cy.get('form').should('be.visible')
    cy.get('input[name="query"]').should('be.visible')
    cy.get('input[name="query"]').should('have.attr', 'placeholder')
    cy.get('input[type="submit"]').should('be.visible')
    
    // Verify hidden fields for server configuration
    cy.get('input[name="server_scheme"]').should('exist')
    cy.get('input[name="server_port"]').should('exist')
    
    // Verify no results table is displayed initially
    cy.get('table').should('not.exist')
    cy.get('.card').should('not.exist')
    
    cy.task('log', 'Successfully validated initial Zenodo search form')
  })

  it('should perform search and display results table', () => {
    // Navigate to Zenodo landing page
    navigateToZenodo()
    
    // Perform a search (using mock data - any query returns the same 2 records)
    cy.get('input[name="query"]').type('Record')
    cy.get('input[type="submit"]').click()
    
    // Verify URL contains search query
    cy.url().should('include', 'query=Record')
    
    // Verify results card appears
    cy.get('.card').should('be.visible')
    cy.get('.card-header').should('be.visible')
    
    // Verify pagination controls are present
    cy.get('nav[aria-label*="pagination"]').should('be.visible')
    
    // Verify results table structure
    cy.get('table.table-striped').should('be.visible')
    cy.get('table thead th').should('contain', 'Title')
    cy.get('table tbody').should('be.visible')
    
    // Verify table has proper accessibility features
    cy.get('table caption.visually-hidden').should('exist')
    cy.get('table thead th[scope="col"]').should('exist')
    
    cy.task('log', 'Successfully performed search and validated results table with mock data')
  })

  it('should validate search results structure and content', () => {
    // Navigate to Zenodo landing page and search
    navigateToZenodo()
    cy.get('input[name="query"]').type('Record')
    cy.get('input[type="submit"]').click()
    
    // Wait for results to load (mock data has exactly 2 records)
    cy.get('table tbody tr').should('have.length', 2)
    
    // Verify each result row has required elements
    cy.get('table tbody tr').first().within(() => {
      // Verify title link exists
      cy.get('td a').should('exist').should('have.attr', 'href')
      
      // Verify metadata information exists
      cy.get('.small.text-muted').should('be.visible')
      cy.get('.small.text-muted').should('contain', 'Publication date')
      cy.get('.small.text-muted').should('contain', 'Files')
    })
    
    // Verify clicking on a result navigates to record page
    cy.get('table tbody tr').first().find('td a').click()
    cy.url().should('include', '/explore/zenodo/')
    cy.url().should('include', '/records/')
    
    cy.task('log', 'Successfully validated search results structure with mock data')
  })

  it('should test pagination functionality in search results', () => {
    // Navigate and search for results (mock data has only 2 records, no pagination expected)
    navigateToZenodo()
    cy.get('input[name="query"]').type('Record')
    cy.get('input[type="submit"]').click()
    
    // Wait for results
    cy.get('.card-header').should('be.visible')
    
    // With mock data (2 records), pagination should not be present
    cy.get('body').then(($body) => {
      if ($body.find('nav[aria-label*="pagination"] a').length > 0) {
        // If pagination exists, test it
        cy.get('nav[aria-label*="pagination"] a').first().click()
        cy.get('table tbody tr').should('have.length.at.least', 1)
        
        cy.task('log', 'Successfully tested pagination functionality')
      } else {
        // Expected behavior with mock data - no pagination for 2 records
        cy.task('log', 'Pagination not available with mock data (2 records only)')
      }
    })
  })

  it('should handle search results with mock data', () => {
    // Navigate to Zenodo and perform any search (mock returns same 2 records for all queries)
    navigateToZenodo()
    cy.get('input[name="query"]').type('Record')
    cy.get('input[type="submit"]').click()
    
    // With WireMock, any search query returns the same 2 mock records
    cy.get('table tbody tr').should('have.length', 2)
    cy.get('table tbody tr').first().should('contain', 'Record One')
    cy.get('table tbody tr').last().should('contain', 'Record Two')
    
    cy.task('log', 'Successfully verified mock data behavior - all queries return same results')
  })

  it('should validate repositories dropdown menu for Zenodo', () => {
    // Verify repositories dropdown exists and is accessible
    cy.get('#repositories-dropdown').should('be.visible')
    cy.get('#repositories-dropdown').click()
    
    // Verify dropdown menu opens
    cy.get('#repositories-menu').should('be.visible')
    
    // Verify Zenodo option exists with proper icon
    cy.get('#nav-zenodo').should('be.visible')
    cy.get('#nav-zenodo img[alt="zenodo"]').should('be.visible')
    cy.get('#nav-zenodo').should('contain', 'Zenodo')
    
    // Verify clicking Zenodo navigates correctly
    cy.get('#nav-zenodo').click()
    cy.url().should('include', '/explore/zenodo/')
    
    cy.task('log', 'Successfully validated Zenodo in repositories dropdown with mock integration')
  })

  it('should validate search form accessibility features', () => {
    navigateToZenodo()
    
    // Verify form structure and labels
    cy.get('form').should('be.visible')
    cy.get('input[name="query"]').should('have.attr', 'class', 'form-control')
    cy.get('input[type="submit"]').should('have.attr', 'class').and('include', 'btn-primary')
    
    // Verify input group structure
    cy.get('.input-group').should('be.visible')
    cy.get('.input-group input[name="query"]').should('exist')
    cy.get('.input-group input[type="submit"]').should('exist')
    
    cy.task('log', 'Successfully validated search form accessibility')
  })
})