const selectors = {
  logoLink: '#logo-link',
  welcomeMessage: '#welcome-message',
  betaMessage: '#beta-message',
  guideLink: '#guide-link',
  createProjectForm: '#create-project-form',
  betaFeedbackLink: '#beta-feedback-link',
};

export class HomePage {
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

  getCreateProjectForm() {
    return cy.get(selectors.createProjectForm);
  }

  getBetaFeedbackLink() {
    return cy.get(selectors.betaFeedbackLink);
  }
}

export default new HomePage();

