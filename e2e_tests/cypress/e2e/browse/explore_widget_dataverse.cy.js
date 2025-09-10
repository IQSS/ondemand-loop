import { visitLoopRoot } from '../../plugins/navigation'

describe('Explore Widget - Dataverse', () => {
  const EXPLORE_INPUT_SELECTOR = '#explore-repo-url-input'
  const EXPLORE_SUBMIT_SELECTOR = '#explore-repo-url-submit'
  const DATAVERSE_URL = Cypress.env('dataverseUrl')

  beforeEach(() => {
    visitLoopRoot()
  })

  it('should navigate to explore dataverse page and verify rendering', () => {
    // Navigate to the homepage first
    visitLoopRoot()

    // Find and interact with the explore widget input
    cy.get(EXPLORE_INPUT_SELECTOR).should('be.visible')
    
    // Enter the Dataverse URL
    cy.get(EXPLORE_INPUT_SELECTOR).clear().type(DATAVERSE_URL)
    
    // Submit the explore form
    cy.get(EXPLORE_SUBMIT_SELECTOR).waitClick()
    
    // Verify that we're on the explore page and it rendered successfully
    cy.url().should('include', '/explore/')
    cy.url().should('include', 'dataverse')
    
    // Verify the page title is correct
    cy.title().should('eq', 'OnDemand Loop - Dataverse Collection')
    
    // Verify breadcrumbs are present and structured correctly
    cy.get('nav[aria-label="Breadcrumb"]').should('be.visible')
    cy.get('.breadcrumb').should('be.visible')
    cy.get('.breadcrumb .breadcrumb-item').should('have.length.at.least', 3)
    
    // Verify specific breadcrumb items
    cy.get('.breadcrumb .breadcrumb-item').first().should('contain', 'Home')
    cy.get('.breadcrumb .breadcrumb-item').eq(1).should('contain', 'Dataverse')
    cy.get('.breadcrumb .breadcrumb-item').eq(2).should('contain', DATAVERSE_URL)
    
    // Verify the main h2 title is present and contains expected text
    cy.get('h2').contains('Sample Dataverse').should('be.visible')
    
    // Verify the search bar is present and functional
    cy.get('form input[name="query"]').should('be.visible')
    cy.get('form input[name="query"]').should('have.attr', 'placeholder', 'Search items within the collection')
    cy.get('form input[value="Search Inside"]').should('be.visible')
    
    // Verify pagination is present
    cy.get('nav[aria-label="Search result pagination"]').should('be.visible')
    cy.get('.card-header').contains('11 to 30 of 195882 results').should('be.visible')
    cy.get('a[aria-label="Go to next page"]').should('be.visible')
    cy.get('a[title="Next page"]').should('be.visible')
    
    // Verify search results list is present
    cy.get('ul.list-group').should('be.visible')
    cy.get('li.list-group-item').should('have.length.at.least', 1)
    
    // Verify collection actions bar
    cy.get('#dataverse-collection-action-bar').should('be.visible')
    cy.get('#dataverse-collection-action-bar button').contains('Create Collection Bundle').should('be.visible')
    cy.get('#dataverse-collection-action-bar a').contains('Open collection on Dataverse').should('be.visible')
    
    cy.task('log', 'Successfully navigated to Dataverse explore page and verified all rendering elements')
  })

  it('should handle explore widget with dataverse URL via explore button', () => {
    // Navigate to the homepage
    visitLoopRoot()

    // Find the explore widget
    cy.get(EXPLORE_INPUT_SELECTOR).should('be.visible')
    
    // Enter the Dataverse URL
    cy.get(EXPLORE_INPUT_SELECTOR).clear().type(DATAVERSE_URL)
    
    // Click the explore button instead of submitting form
    cy.get(EXPLORE_SUBMIT_SELECTOR).waitClick()
    
    // Verify navigation to explore page
    cy.url().should('include', '/explore/')
    
    // Verify page loads successfully
    cy.get('body').should('contain', 'Dataverse')
    
    cy.task('log', 'Successfully explored Dataverse via explore button')
  })

  it('should validate explore widget is present on homepage', () => {
    // Verify the explore widget exists and is properly structured
    cy.get('#app-actions-bar .explore-repo').should('be.visible')
    cy.get(EXPLORE_INPUT_SELECTOR).should('be.visible')
    cy.get(EXPLORE_INPUT_SELECTOR).should('have.attr', 'placeholder')
    cy.get(EXPLORE_SUBMIT_SELECTOR).should('be.visible')

    cy.task('log', 'Explore widget validation completed')
  })

  it('should test search functionality within dataverse collection', () => {
    // Navigate to dataverse collection first
    cy.get(EXPLORE_INPUT_SELECTOR).clear().type(DATAVERSE_URL)
    cy.get(EXPLORE_SUBMIT_SELECTOR).click()
    
    // Wait for page to load and verify we're on the collection page
    cy.get('h2').contains('Sample Dataverse').should('be.visible')
    
    // Test search functionality within the collection
    cy.get('form input[name="query"]').type('replication data')
    cy.get('form input[value="Search Inside"]').click()
    
    // Verify search results are displayed
    cy.url().should('include', 'query=replication+data')
    cy.get('ul.list-group').should('be.visible')
    
    // Verify search results contain the search term
    cy.get('li.list-group-item').should('contain.text', 'Replication Data')
    
    cy.task('log', 'Successfully tested search functionality within Dataverse collection')
  })

  it('should test pagination navigation in dataverse collection', () => {
    // Navigate to dataverse collection
    cy.get(EXPLORE_INPUT_SELECTOR).clear().type(DATAVERSE_URL)
    cy.get(EXPLORE_SUBMIT_SELECTOR).click()
    
    // Verify we're on page 1
    cy.get('.card-header').contains('11 to 30 of 195882 results').should('be.visible')
    
    // Click next page
      cy.get('a[data-test="header-pagination-next"]').click()
    
    // Verify we're now on page 2
    cy.url().should('include', 'page=2')
    cy.get('ul.list-group').should('be.visible')
    cy.get('li.list-group-item').should('have.length.at.least', 1)
    
    cy.task('log', 'Successfully tested pagination navigation in Dataverse collection')
  })
})