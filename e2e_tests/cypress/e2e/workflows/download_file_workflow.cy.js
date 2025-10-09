import homePage from '../../pages/HomePage'
import projectIndexPage from '../../pages/ProjectIndexPage'
import projectDetailsPage from '../../pages/ProjectDetailsPage'
import downloadsPage from '../../pages/DownloadsPage'
import dataverse from '../../pages/connectors/Dataverse'
import flashMessageComponent from '../../pages/FlashMessageComponent'

describe('Workflow: Download Files from Dataverse', () => {
  const PROJECT_NAME = 'DownloadFileWorkflow'
  let projectId

  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  after(() => {
    // Cleanup: Delete the project after the test
    if (projectId) {
      projectIndexPage.visit()
      projectIndexPage.deleteProject(projectId)
      cy.task('log', `Cleaned up project: ${projectId}`)
    }
  })

  it('should complete full workflow: create project, download files from dataverse, and verify downloads', () => {
    cy.task('log', 'Starting download file workflow test')
    cy.task('log', 'Step 0: Cleanup')
    projectIndexPage.deleteProjects()

    // Step 1: Create a new project
    cy.task('log', 'Step 1: Creating new project')
    projectIndexPage.visit()
    projectIndexPage.getPageContainer().should('be.visible')
    projectIndexPage.clickCreateProject()

    // Verify project creation
    flashMessageComponent.getFlashAlert().should('contain', 'created')
    projectDetailsPage.assertInProjectDetails()

    // Store project ID for cleanup
    projectDetailsPage.getProjectId().then(projectId => {
      cy.wrap(projectId).as('projectId')
      cy.task('log', `Created project with ID: ${projectId}`)
    })

    // Step 2: Edit project name to "DownloadFileWorkflow"
    cy.task('log', 'Step 2: Editing project name')
    projectDetailsPage.waitClickEditProjectName()
    projectDetailsPage.typeProjectName(PROJECT_NAME)
    projectDetailsPage.clickSaveName()

    // Verify the name has been updated
    projectDetailsPage.getProjectName().should('contain', PROJECT_NAME)
    cy.task('log', `Project renamed to: ${PROJECT_NAME}`)

    // Step 3: Add files from URL - Enter Dataverse URL
    cy.task('log', 'Step 3: Adding files from Dataverse URL')
    projectDetailsPage.toggleAddFilesFromUrl()

    // Wait for the repo resolver to be visible
    projectDetailsPage.getDownloadRepoResolver().should('be.visible')

    // Enter the Dataverse URL in the repo resolver input
    projectDetailsPage.getDownloadRepoResolverInput().clear().type(dataverse.DATAVERSE_URL)
    projectDetailsPage.submitDownloadRepoResolver()
    cy.task('log', `Exploring Dataverse URL: ${dataverse.DATAVERSE_URL}`)

    // Step 4: Browse the collection and select a dataset
    cy.task('log', 'Step 4: Browsing collection and selecting dataset')

    // Wait for the collection page to load
    cy.get('h2').contains('Sample Dataverse').should('be.visible')

    // Verify we're on the browse/explore page
    cy.url().should('include', '/explore/')

    // Select the first dataset from the collection
    cy.get('ul.list-group').should('be.visible')
    cy.get('li.list-group-item').should('have.length.at.least', 1)

    // Click on the first dataset link
    cy.get('li.list-group-item').first().find('a').first().click()
    cy.task('log', 'Selected first dataset from collection')

    // Step 5: Browse files and download all files
    cy.task('log', 'Step 5: Browsing files and downloading')

    // Wait for the dataset page to load with files
    cy.get('body').should('contain', 'Files')

    // SELECT ALL FILES AND SUBMIT FORM
    dataverse.selectAllFiles()
    dataverse.submitFilesToProject()

    cy.task('log', 'Initiated file downloads')

    // Step 6: Assert success message
    cy.task('log', 'Step 6: Verifying success message')
    cy.wait(1000) // Brief wait for the action to complete
    flashMessageComponent.getFlashAlert().should('be.visible')

    // Wait a moment for downloads to be registered
    cy.wait(2000)

    // Step 7: Navigate to Downloads page and verify downloads
    cy.task('log', 'Step 7: Navigating to Downloads page')
    downloadsPage.visit()

    // Verify we're on the downloads page
    cy.url().should('include', '/downloads')
    cy.get('body').should('contain', 'Downloads')

    downloadsPage.getDownloadsList().should('be.visible')
    downloadsPage.getDownloadFileRows().should('have.length', 2)
    downloadsPage.assertAllDownloadFilesWithStatus('success')

    // Step 8: Navigate to project details and verify downloads in Downloads tab
    cy.task('log', 'Step 8: Verifying downloads in project Downloads tab')

    // Navigate to project index, then to the specific project
    projectIndexPage.visit()
    cy.get('@projectId').then(projectId => {
      projectIndexPage.getProjectSummaryById(projectId).should('exist')
      return projectIndexPage.getProjectNameLink(projectId).click()
    })

    // Verify we're back on the project details page
    projectDetailsPage.assertInProjectDetails()

    // Click on the Downloads tab
    projectDetailsPage.clickDownloadTab()
    cy.task('log', 'Clicked Downloads tab')

    // Verify downloads are shown in the tab
    projectDetailsPage.getDownloadFilesList().should('be.visible')
    projectDetailsPage.getDownloadFileRows().should('have.length.at.least', 1)

    cy.task('log', 'Verified downloads in project Downloads tab')
    cy.task('log', 'Workflow completed successfully!')
  })
})
