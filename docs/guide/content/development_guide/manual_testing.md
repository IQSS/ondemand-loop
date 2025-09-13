# Manual Testing & Verification

This guide provides a systematic approach to manually verify that **OnDemand Loop** functions correctly end-to-end. Manual testing complements automated testing by covering user experience aspects, visual validation, and integration scenarios that are difficult to automate.

!!! tip "When to Use Manual Testing"
    Manual testing is particularly valuable for:
    
    - **Pre-release validation** - Comprehensive verification on staging environments before production deployment
    - **Production deployment verification** - Confirming critical workflows function correctly in live environment
    - **Cross-environment validation** - Ensuring functionality works across different deployment configurations
    - **Bug investigation** - Reproducing and understanding issues reported by users in deployed environments
    - **Cross-browser testing** - Ensuring compatibility across different browsers and devices in real deployment conditions
    - **Integration testing** - Validating external service integrations (repositories, file systems) in deployed environments

---

### Prerequisites

Manual verification should be performed on **deployed environments** (staging, production, or test instances) rather than local development environments. Before beginning manual verification:

- **Identify target environment** - staging, production, or dedicated test environment
- **Ensure environment access** - appropriate credentials and network access to the deployed instance
- **Verify environment status** - application is running and accessible via web browser
- **Gather test data** - valid repository URLs, API credentials, and sample datasets for testing
- **Coordinate with team** - ensure testing won't interfere with other users or ongoing operations

!!! warning "Environment Considerations"
    - **Production testing** should be limited and coordinated with operations team
    - **Staging environments** are ideal for comprehensive manual verification
    - **Local development** environments are better suited for automated testing and development workflows

---

### 1. Navigation & UI Components

#### Core Navigation Testing
1. **Logo & Branding**: Verify OnDemand Loop logo displays correctly in top navigation
2. **Logo Navigation**: Click logo to confirm it returns to home page  
3. **Primary Navigation**: Test **Projects**, **Downloads**, and **Uploads** links load their respective pages
4. **Repository Dropdown**: Access **Repositories** menu for Dataverse, Zenodo, and **Settings** links
5. **External Links**: Verify **Open OnDemand** link opens dashboard in new tab
6. **Help Menu**: Open **Help** dropdown to test:
   - Guide link (opens in new tab)
   - Sitemap link functionality  
   - Restart action
   - Reset App confirmation modal
7. **Responsive Design**: Test navigation menu collapse/expand on mobile viewport

---

### 2. Home Page

#### Welcome Experience
1. **Page Access**: Visit home page via logo click or root URL
2. **Welcome Content**: Verify welcome card displays guide link and **Create Project** button
3. **Quick Actions**: Test **Create Project** button triggers project creation flow
4. **User Notices**: Confirm beta notice alert is visible and informative
5. **Page Layout**: Check overall page layout and responsiveness

---

### 3. Project Management

#### Project Lifecycle
1. **Project Creation**: Create new project via navigation bar or home page **Create Project** button
2. **Project Naming**: Test rename functionality using the pencil icon next to project title
3. **Active Project**: Verify only one project can be active at a time using pin icon or dropdown selector
4. **Project Navigation**: Confirm project appears in application bar dropdown
5. **File System Integration**: Open workspace and metadata folders via folder icons (should open in Open OnDemand Files app)
6. **Project Persistence**: Delete project and verify files remain on disk if configured
7. **Project Details Page**: Verify project details page displays correctly with all expected elements

---

### 4. Data Discovery & Repository Integration

#### Repository Browsing
1. **Direct Dataset Access**: Paste dataset DOI or URL into **Explore** bar and verify dataset loads
2. **Repository Browsing**: Use **Repositories** menu to browse supported repositories:
   - Test Dataverse connector and search functionality
   - Test Zenodo connector and search functionality
3. **Repository Activity**: Open **Repository Activity** list and reopen a recently viewed dataset
4. **Search Results**: Verify search results display correctly with metadata and file listings
5. **Dataset Navigation**: Test navigation between dataset details and file views

---

### 5. File Download Workflow

#### Download Management
1. **File Selection**: On dataset page, select one or more files and click **Add Files to Project**
2. **Download Queue**: Verify files appear in active project's **Downloads** tab with accurate metadata and status
3. **Download Status Monitoring**: Visit global **Downloads** page and confirm:
   - Queued downloads display correctly
   - Running downloads show progress updates
   - Status updates occur automatically
4. **File Completion**: Confirm completed files exist in project workspace directory
5. **Download Management**: Test download cancellation and file deletion functionality
6. **Error Handling**: Verify failed downloads display appropriate error messages

---

### 6. File Upload Workflow

#### Upload Management  
1. **Upload Bundle Creation**: From project page, create **Upload Bundle** with target dataset or collection URL
2. **Repository Authentication**: Add or edit required API key and complete repository-specific setup
3. **File Staging**: Use **Add Files** to open upload file selector and stage files or folders
4. **Upload Monitoring**: Monitor file progress in:
   - Bundle view for individual upload details
   - Global **Uploads** page for all upload activity
5. **Upload Management**: Test upload cancellation and verify status updates correctly
6. **Upload Completion**: Verify successful uploads reflect in target repository  
7. **Error Handling**: Test behavior with invalid API keys or network issues

---

### 7. Repository Configuration & Settings

#### Credential Management
1. **Settings Access**: Open **Repositories → Settings** from navigation bar
2. **Credential Management**: Verify previously used repositories appear with options to:
   - Edit existing API keys
   - Remove stored credentials
   - Add new repository connections
3. **Security**: Confirm API keys are properly masked/hidden in the interface
4. **Repository Status**: Test connection status indicators for configured repositories

---

### 8. Additional System Checks

#### Error Handling & Edge Cases
1. **Error Handling**: Test application behavior with:
   - Invalid URLs/DOIs in explore bar
   - Network connectivity issues
   - Invalid API credentials
2. **Flash Messages**: Verify success/error messages display properly throughout workflows
3. **Application State**: Test browser refresh behavior on different pages
4. **File Browser Integration**: Verify seamless integration with Open OnDemand Files app
5. **Performance**: Check page load times and responsiveness during file operations

---

### Verification Checklist

Use this checklist to track testing progress:

#### Navigation & Interface
- [ ] Logo and branding display correctly
- [ ] All navigation links function properly
- [ ] Help menu and external links work
- [ ] Responsive design on mobile devices

#### Core Functionality
- [ ] Project creation and management
- [ ] Dataset discovery via explore bar
- [ ] Repository browsing (Dataverse & Zenodo)
- [ ] File download workflow
- [ ] File upload workflow
- [ ] Repository settings management

#### Error Handling
- [ ] Invalid input handling
- [ ] Network error scenarios
- [ ] Authentication failures
- [ ] Flash message display

#### Integration
- [ ] Open OnDemand Files app integration
- [ ] Repository API connectivity
- [ ] File system operations

---

### Reporting Issues

When manual testing reveals issues:

1. **Document the steps** to reproduce the problem
2. **Include environment details** (browser, OS, OnDemand version)
3. **Capture screenshots** for visual issues
4. **Check console logs** for JavaScript errors
5. **File issues** in the project's GitHub repository with the `bug` label

---

### Best Practices

- **Test systematically** - Follow the verification order to catch dependency issues
- **Use fresh projects** - Create new test projects to avoid state contamination
- **Test edge cases** - Try boundary conditions and unusual input
- **Document findings** - Keep notes of both successful and failed test cases
- **Cross-reference with automated tests** - Ensure manual testing covers gaps in automated coverage

This manual verification process ensures OnDemand Loop functions reliably across all major workflows and provides confidence for releases and deployments.