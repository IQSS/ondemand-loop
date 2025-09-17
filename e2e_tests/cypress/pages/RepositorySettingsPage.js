const selectors = {
  repositoriesDropdown: '#repositories-dropdown',
  navRepoSettingsLink: '#nav-repo-settings',
};

export class RepositorySettingsPage {
  visit() {
    cy.get(selectors.repositoriesDropdown).click();
    cy.get(selectors.navRepoSettingsLink).click();
    cy.title().should('match', /repository settings/i)
  }
}

export default new RepositorySettingsPage();