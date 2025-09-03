import { visitLoopRoot } from '../plugins/navigation'
import { deleteAllProjects } from '../plugins/projects'

describe('Home page', () => {
  beforeEach(() => {
    visitLoopRoot()
  })

  it('shows welcome and beta notices on first visit', () => {
    // CLEANUP TO SEE THE WELCOME MESSAGE
    deleteAllProjects();
    // Visit the page with authentication using navigation utility
    visitLoopRoot();
    
    // Try to find the expected content, but don't fail immediately
    cy.get('body').then(($body) => {
      cy.contains('Welcome to OnDemand Loop!').should('be.visible');
      cy.contains('Beta Notice').should('be.visible');
    });

    cy.task('log', 'Test completed successfully using cy.loop configuration');

  });
});
