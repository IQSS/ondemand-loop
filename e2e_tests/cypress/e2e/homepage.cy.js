import { visitLoopRoot } from '../plugins/navigation'

describe('Home page', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('shows welcome and beta notices', () => {
    visitLoopRoot();
    
    // Try to find the expected content, but don't fail immediately
    cy.get('body').then(($body) => {
      cy.contains('Welcome to OnDemand Loop!').should('be.visible');
      cy.contains('Beta Notice').should('be.visible');
    });

    cy.task('log', 'Test completed successfully using cy.loop configuration');

  });
});
