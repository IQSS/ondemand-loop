const NAVIGATION = {
  baseUrl: Cypress.env('baseUrl'),
  dashboardPath: Cypress.env('dashboardPath'),
  loopPath: Cypress.env('loopPath'),
};

const selectors = {
  logoLink: '#logo-link',
  welcomeMessage: '[data-test-id="welcome-message"]',
  betaMessage: '[data-test-id="beta-message"]',
  guideLink: '[data-test-id="guide-link"]',
  createProjectButton: '[data-test-id="home-create-project-btn"]',
  betaFeedbackLink: '[data-test-id="beta-feedback-link"]',
};

export class HomePage {

  visitLoopRoot() {
    const auth = cy.loop.auth;
    const timeout = cy.loop.timeout;
    cy.visit(NAVIGATION.loopPath, {
      auth,
      failOnStatusCode: false,
      timeout
    });
  }

  visit() {
    cy.get(selectors.logoLink).click();
  }

  getWelcomeMessage() {
    return cy.get(selectors.welcomeMessage);
  }

  getBetaMessage() {
    return cy.get(selectors.betaMessage);
  }

  getGuideLink() {
    return cy.get(selectors.guideLink);
  }

  getCreateProjectButton() {
    return cy.get(selectors.createProjectButton);
  }

  getBetaFeedbackLink() {
    return cy.get(selectors.betaFeedbackLink);
  }
}

export default new HomePage();

