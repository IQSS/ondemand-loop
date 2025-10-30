import homePage from '../../pages/HomePage'
import projectIndexPage from '../../pages/ProjectIndexPage'
import projectDetailsPage from '../../pages/ProjectDetailsPage'
import uploadsPage from '../../pages/UploadsPage'
import dataverse from '../../pages/connectors/Dataverse'
import flashMessageComponent from '../../pages/FlashMessageComponent'
import fileBrowserComponent from '../../pages/FileBrowserComponent'

describe('Workflow: Upload Files to Dataverse', () => {
  const PROJECT_NAME = 'UploadFileWorkflow'
  const API_KEY = 'test-api-key-12345'
  const UPLOAD_FILE = 'upload_file.txt'

  beforeEach(() => {
    homePage.visitLoopRoot()
  })

  it('should complete full workflow: create project, upload files to dataverse, and verify uploads', () => {
    cy.task('log', 'Starting upload file workflow test')
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

    cy.get('[data-project-id]').invoke('attr', 'data-project-id').as('projectId')
    cy.get('@projectId').then(projectId => {
      cy.task('log', `Created project with ID: ${projectId}`)
    })

    // Step 2: Edit project name to "UploadFileWorkflow"
    cy.task('log', 'Step 2: Editing project name')
    projectDetailsPage.waitClickEditProjectName()
    projectDetailsPage.typeProjectName(PROJECT_NAME)
    projectDetailsPage.clickSaveName()

    // Verify the name has been updated
    projectDetailsPage.getProjectName().should('contain', PROJECT_NAME)
    cy.task('log', `Project renamed to: ${PROJECT_NAME}`)

    // Step 3: Create upload bundle using Dataverse URL
    cy.task('log', 'Step 3: Creating upload bundle with Dataverse URL')
    projectDetailsPage.clickCreateUploadBundle()
    projectDetailsPage.createUploadBundle(dataverse.DATAVERSE_URL)
    cy.task('log', `Created upload bundle for: ${dataverse.DATAVERSE_URL}`)

    // Wait for upload bundle to be created and get its ID
    cy.wait(1000) // Brief wait for the bundle to be created
    // Store project ID for cleanup
    cy.get('[data-upload-bundle-id]').first().invoke('attr', 'data-upload-bundle-id').as('bundleId')
    cy.get('@bundleId').then(bundleId => {
      cy.task('log', `Created upload bundle with ID: ${bundleId}`)
    })

    // Step 4: Add API key
    cy.task('log', 'Step 4: Adding API key')
    dataverse.clickEditApiKey()
    // Wait for modal to load
    cy.get('#global-modal').should('be.visible')

    dataverse.enterApiKey(API_KEY)
    dataverse.saveApiKey()
    cy.task('log', 'API key added successfully')

    // Wait for modal to close
    cy.wait(1000)

    // Step 5: Select a collection
    cy.task('log', 'Step 5: Selecting collection')
    dataverse.clickSelectCollection()

    // Wait for modal to load with collections
    dataverse.getModal().should('be.visible')
    dataverse.getSelectCollectionItems().should('exist')

    dataverse.selectFirstCollection()
    dataverse.submitSelectCollectionForm()
    cy.task('log', 'Selected first collection from list')

    // Wait for modal to close
    cy.wait(1000)

    // Step 6: Select a dataset
    cy.task('log', 'Step 6: Selecting dataset')
    dataverse.clickSelectDataset()

    // Wait for modal to load with datasets
    dataverse.getModal().should('be.visible')
    dataverse.getSelectDatasetItems().should('exist')

    dataverse.selectFirstDataset()
    dataverse.submitSelectDatasetForm()
    cy.task('log', 'Selected first dataset from list')

    // Step 7: Click add files to open file browser
    cy.task('log', 'Step 7: Opening file browser to select upload file')
    cy.get('@bundleId').then(bundleId => {
      projectDetailsPage.clickUploadBundleAddFiles(bundleId)
      return projectDetailsPage.getUploadBundleFileBrowser(bundleId).find('nav').should('exist')
    })
    cy.task('log', 'File browser opened')



    // Step 8: Navigate to /home/ood using home icon
    cy.task('log', 'Step 8: Navigating to /home/ood directory')
    fileBrowserComponent.clickFileBrowserHome()
    // Wait for navigation
    cy.wait(500)

    // Step 9: Select upload_file.txt by double click
    cy.task('log', 'Step 9: Selecting upload_file.txt')
    fileBrowserComponent.selectFileByDoubleClick(UPLOAD_FILE)
    cy.wait(1000)
    cy.task('log', `Selected file: ${UPLOAD_FILE}`)
    // Step 10: Close file browser
    cy.task('log', 'Step 10: Closing file browser')
    fileBrowserComponent.closeFileBrowser()

    // Step 11: Assert file is in the upload bundle list
    cy.task('log', 'Step 11: Verifying file is in upload bundle')
    cy.get('@bundleId').then(bundleId => {
      projectDetailsPage.getUploadBundleFilesList(bundleId).should('be.visible')
      projectDetailsPage.getUploadFileRows(bundleId).should('have.length', 1)
      projectDetailsPage.getUploadFileRows(bundleId).first().invoke('attr', 'data-upload-file-id').as('fileId')
      return projectDetailsPage.getUploadFileRows(bundleId).should('contain', UPLOAD_FILE)
    })
    cy.task('log', 'File appears in upload bundle file list')

    // Step 12: Navigate to Uploads page and verify file with success status
    cy.task('log', 'Step 12: Navigating to Uploads page')
    uploadsPage.visit()

    // Verify we're on the uploads page
    uploadsPage.assertInUploads()

    uploadsPage.getUploadsList().should('be.visible')
    uploadsPage.getUploadFileRows().should('have.length.at.least', 1)
    uploadsPage.getUploadFileRows().should('contain', UPLOAD_FILE)
    uploadsPage.assertAllUploadFilesWithStatus('success')
    cy.task('log', 'Verified file in Uploads page with success status')

    // Step 13: Navigate to project details and verify in upload bundle tab
    cy.task('log', 'Step 13: Verifying file in project upload bundle tab')

    // Navigate to project index, then to the specific project
    cy.get('@projectId').then(projectId => {
      cy.task('log', `Navigate to project details`)
      projectIndexPage.visit()
      projectIndexPage.getProjectSummaryById(projectId).should('exist')
      return projectIndexPage.getProjectNameLink(projectId).click()
    })

    // Verify we're back on the project details page
    projectDetailsPage.assertInProjectDetails()

    cy.get('@bundleId').then(bundleId => {
      // Click on the upload bundle tab
      projectDetailsPage.clickUploadBundleTab(bundleId)
      cy.task('log', 'Clicked upload bundle tab')
      // Verify file is shown in the upload bundle with success status
      projectDetailsPage.getUploadBundleFilesList(bundleId).should('be.visible')
      projectDetailsPage.getUploadFileRows(bundleId).should('have.length', 1)
      cy.get('@fileId').then(fileId => {
        projectDetailsPage.getUploadFileRowById(bundleId, fileId).should('contain', UPLOAD_FILE)
        projectDetailsPage.getUploadFileRowById(bundleId, fileId).should('contain', 'success')
      })
    })
    cy.task('log', 'Verified file in upload bundle tab with success status')
    cy.task('log', 'Workflow completed successfully!')
  })
})
