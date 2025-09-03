export const NAVIGATION = {
  baseUrl: Cypress.env('baseUrl'),
  dashboardPath: Cypress.env('dashboardPath'),
  loopPath: Cypress.env('loopPath'),
}

export const PAGE_TITLES = {
  projects: 'Projects',
  downloads: 'Downloads',
  uploads: 'Uploads',
  repositorySettings: 'Repository Settings',
  dataverse: 'Dataverse Landing',
  zenodo: 'Zenodo'
}

export const visitLoopRoot = () => {
  const auth = cy.loop.auth
  const timeout = cy.loop.timeout
  cy.visit(NAVIGATION.loopPath, { 
    auth, 
    failOnStatusCode: false, 
    timeout 
  })
}

export const navigateToProjects = () => {
  cy.get('#nav-projects').click()
  cy.get('h1').should('contain', PAGE_TITLES.projects)
}

export const navigateToDownloads = () => {
  cy.get('#nav-downloads').click()
  cy.get('h1').should('contain', PAGE_TITLES.downloads)
}

export const navigateToUploads = () => {
  cy.get('#nav-uploads').click()
  cy.get('h1').should('contain', PAGE_TITLES.uploads)
}

export const navigateToDataverse = () => {
  cy.get('#repositoriesDropdown').click()
  cy.get('#nav-dataverse').click()
  cy.get('body').should('contain', PAGE_TITLES.dataverse)
}

export const navigateToZenodo = () => {
  cy.get('#repositoriesDropdown').click()
  cy.get('#nav-zenodo').click()
  cy.get('body').should('contain',  PAGE_TITLES.zenodo)
}

export const navigateToRepositorySettings = () => {
  cy.get('#repositoriesDropdown').click()
  cy.get('#nav-repo-settings').click()
  cy.get('h1').should('contain', PAGE_TITLES.repositorySettings)
}

export const navigateToHome = () => {
  cy.get('#logo-link').click()
  cy.url().should('include', NAVIGATION.loopPath)
}