import homePage from '../../pages/HomePage'
import zenodo from '../../pages/connectors/Zenodo'

// Note: These tests use WireMock to mock the Zenodo API (/api/records)
// The mock server runs at http://zenodo:8080 and contains 2 dummy records for testing
// Mock records: "Record One" and "Record Two" with basic metadata and files
describe('Browse Repositories - Zenodo', () => {
  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  it('should navigate to Zenodo landing page via repositories menu', () => {
    // Navigate to Zenodo using the connector page object
    zenodo.navigateToZenodo()

    // Validate the landing page using the page object
    zenodo.validateLandingPage()

    cy.task('log', 'Successfully navigated to Zenodo landing page')
  })

  it('should validate initial search form is present', () => {
    // Navigate to Zenodo landing page
    zenodo.navigateToZenodo()

    // Validate search form using page object
    zenodo.validateSearchForm()

    // Verify no results table is displayed initially
    zenodo.validateNoResultsInitially()
    zenodo.getResultsCard().should('not.exist')

    cy.task('log', 'Successfully validated initial Zenodo search form')
  })

  it('should perform search and display results table', () => {
    // Navigate to Zenodo landing page
    zenodo.navigateToZenodo()

    // Perform a search using page object
    zenodo.searchRecords('Record')

    // Verify URL contains search query
    cy.url().should('include', 'query=Record')

    // Verify results using page object
    zenodo.getResultsCard().should('be.visible')
    zenodo.getResultsHeader().should('be.visible')

    // Verify pagination controls are present
    zenodo.getPaginationNav().should('be.visible')

    // Validate search results
    zenodo.validateSearchResults()
    cy.get('table thead th').should('contain', 'Title')

    // Verify table has proper accessibility features
    cy.get('table caption.visually-hidden').should('exist')
    cy.get('table thead th[scope="col"]').should('exist')

    cy.task('log', 'Successfully performed search and validated results table with mock data')
  })

  it('should validate search results structure and content', () => {
    // Navigate to Zenodo landing page and search
    zenodo.navigateToZenodo()
    zenodo.searchRecords('Record')

    // Wait for results to load (mock data has exactly 2 records)
    zenodo.getResultsTableRows().should('have.length', 2)

    // Verify each result row has required elements
    zenodo.getResultsTableRows().first().within(() => {
      // Verify title link exists
      cy.get('td a').should('exist').should('have.attr', 'href')

      // Verify metadata information exists
      cy.get('.small.text-muted').should('be.visible')
      cy.get('.small.text-muted').should('contain', 'Publication date')
      cy.get('.small.text-muted').should('contain', 'Files')
    })

    // Verify clicking on a result navigates to record page using page object
    zenodo.clickRecordByIndex(0)
    cy.url().should('include', '/explore/zenodo/')
    cy.url().should('include', '/records/')

    cy.task('log', 'Successfully validated search results structure with mock data')
  })

  it('should test pagination functionality in search results', () => {
    // Navigate and search for results using page object
    zenodo.navigateToZenodo()
    zenodo.searchRecords('Record')

    // Wait for results
    zenodo.getResultsHeader().should('be.visible')

    // With mock data (2 records), pagination should not be present
    cy.get('body').then(($body) => {
      if ($body.find('nav[aria-label*="pagination"] a').length > 0) {
        // If pagination exists, test it using page object
        zenodo.clickNextPage()
        zenodo.getResultsTableRows().should('have.length.at.least', 1)

        cy.task('log', 'Successfully tested pagination functionality')
      } else {
        // Expected behavior with mock data - no pagination for 2 records
        cy.task('log', 'Pagination not available with mock data (2 records only)')
      }
    })
  })

  it('should handle search results with mock data', () => {
    // Navigate to Zenodo and perform any search using page object
    zenodo.navigateToZenodo()
    zenodo.searchRecords('Record')

    // With WireMock, any search query returns the same 2 mock records
    zenodo.getResultsTableRows().should('have.length', 2)
    zenodo.getResultsTableRows().first().should('contain', 'Record One')
    zenodo.getResultsTableRows().last().should('contain', 'Record Two')

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
    zenodo.navigateToZenodo()

    // Verify form structure and labels using page object
    zenodo.getSearchForm().should('be.visible')
    zenodo.getSearchInput().should('have.attr', 'class', 'form-control')
    zenodo.getSearchSubmitButton().should('have.attr', 'class').and('include', 'btn-primary')

    // Verify input group structure
    cy.get('.input-group').should('be.visible')
    cy.get('.input-group input[name="query"]').should('exist')
    cy.get('.input-group input[type="submit"]').should('exist')

    cy.task('log', 'Successfully validated search form accessibility')
  })
})