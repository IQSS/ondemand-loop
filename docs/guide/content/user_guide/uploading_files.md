# Uploading Files

OnDemand Loop allows you to upload files from your HPC environment to supported remote repositories.  
Uploads are organized into **Upload Bundles**, which group a set of files and link them to a specific dataset in a remote repository.

---

### How to Upload Files

1. **Create an Upload Bundle**  
   From the project detail page, click **Create Upload Bundle** and paste the URL of the remote dataset or collection.  
   Loop will analyze the URL, detect the repository, and name the bundle based on the repository domain.

2. **Configure Authentication (API Token or Personal Access Key)**  
   Each upload bundle requires an API key for authentication.
    - If no key is present, a red badge appears in the bundle header.
    - Click the **pencil icon** to enter your key and choose whether to save it globally or only for this bundle.

3. **Select or Create a Dataset**  
   Depending on the type of URL provided and the rules of the remote repository,  
   additional steps may be required before files can be uploaded.

   The interface will guide you through any necessary actions to fully configure the dataset destination.  
   These actions may include:

    - Selecting a dataset from within a collection
    - Creating a new dataset if required or desired
    - Fetching additional metadata from the repository

   Once these steps are complete, the upload bundle is linked to the appropriate dataset and ready for file staging.

4. **Add Files**  
   Once the bundle is configured, click **Add Files** to open the **Upload File Selector**.
   Use this interface to navigate your HPC project directory and select the files to be uploaded.
   For help using the Upload File Selector, see [Upload File Selector](./upload_file_selector.md).

   Once selected, files are automatically staged and uploaded. You can monitor progress in the bundle view or the global **Uploads** page.  
   Upload tasks can be cancelled before or during transfer.s

!!! note

    This view does **not auto-refresh**. Reload the page manually to see updated statuses.

---

### Creating an Upload Bundle

An **Upload Bundle** links a group of files in your project to a single dataset in a remote repository.  
Each bundle targets **one dataset** and requires:

- A valid **dataset or collection URL**
- An **API key** for authentication
- Local files staged for upload

#### Supported Repository URLs

**Dataverse** accepts:

- **Dataverse URL**  
  Used to list collections you have access to. You'll be prompted to select one in a modal window.

- **Collection URL**  
  Lists datasets inside the collection. You can select or create a dataset.

- **Dataset URL**  
  Files will be uploaded directly into this existing dataset.

**Zenodo** accepts:

- **Deposition URL**  
  Must be a draft deposition. Files are uploaded directly to the specified record.

!!! warning

    Make sure you add an API key **before uploading files**.
    The system will not upload any files without valid credentials.

---

### Project Detail Page – Upload Bundles Tab
Each project shows a dedicated tab for every upload bundle. A new tab is created automatically when a bundle is added.
Each **Upload Bundle** tab provides controls for managing uploads, reviewing repository settings, and tracking the status of staged files.

#### Upload Bundle Tab Header
- **Creation Date** – The data when the bundle was created.
- **Bundle Name** – The name of the bundle based on the repository domain.
- **File Summary Widget** – Displays counts for pending, completed, or failed files. The large circular indicator highlights the percentage of completed downloads.
- **Add Files** – Opens the [upload file selector](./upload_file_selector.md) to choose files from your HPC filesystem.
- **Delete Bundle** – Removes the bundle and its associated uploads from the interface.

#### Connector-Specific Information
This section appears below the header and includes:

- **Repository Icon and Type** – Identifies the remote repository connector.
- **Dataset Name and URL** – The destination dataset for uploaded files. Links to the remote repository for verification of the uploads.
- **API Key Status** – Shows whether a valid API key is configured.
- **Edit Button** – Lets you manage connector specific settings like the API key.

#### Metadata Fields
**Scheduled Date:** When the file was queued for upload.  
**Filename:** Name of the file as it will appear in the remote repository.  
**Size:** File size reported by the local filesystem.  
**Status:** The current upload state. One of: `pending`, `uploading`, `success`, `error`, `cancelled`.  
**Completion Date:** When the file upload finished (or failed).  
**Delete Action:** Removes the file from the upload queue (does not delete the file from disk).

!!! note

    This view does **not auto-refresh**. Reload manually to see updates.

---

### Global Uploads Page
The **Uploads** page provides a real-time view of all upload tasks across all projects.
It is updated automatically every 5 seconds and reflects the most recent activity at the top.

#### Uploads Page Header
At the top of the global Uploads page, a summary panel displays the current system-wide upload state and job activity.

- **Job Status Icon**  
  Indicates whether a background upload job is running:
    - **Play icon** – Upload job is currently processing files.
    - **Pause icon** – No upload task is currently running.

- **Start Time**  
  Shows the time when the current upload job started.

- **Elapsed Time**  
  Indicates how long the job has been running.

- **Status Summary Counters**  
  A live summary of all uploads:
    - **Pending** – Files queued for upload.
    - **In Progress** – Files currently being uploaded.
    - **Completed** – Files uploaded successfully.
    - **Total** – Total number of files in the current batch.

#### Metadata Fields

**Link to File Location:** Direct path to the file on the HPC filesystem.  
**Scheduled Date:** When the file was added to the upload queue.  
**Repository Badge:** Shows the target repository (e.g., Zenodo, Dataverse).  
**Project Name:** The project the upload belongs to. Click to open the Upload Bundles tab.  
**Filename:** The name (and relative path) assigned to the file and used for upload.  
**Size:** File size as reported by the filesystem.  
**Progress Bar:** Visual indicator shown while a file is uploading. Updates every 5 seconds.  
**Status:** One of: `pending`, `uploading`, `success`, `error`, `cancelled`.  
**Cancel Action:** Cancel available only for files in `pending` or `uploading` status.  

#### Behavior

- Uploads are queued and run as system resources allow.
- Progress bars update live for active uploads.
- Completed uploads remain visible on the Uploads page for **24 hours**.
- Files are always listed under the appropriate project's **Upload Bundles** tab.
- Files are sorted in the following order:
    1. `uploading`
    2. `pending`
    3. `completed` (newest first)

!!! warning

    Files cannot be deleted directly from the global **Uploads** page. 
    To remove a file, go to the corresponding project and use the **Delete** action inside the appropriate upload bundle.
    Click the project name to jump directly to its Upload Bundles tab.
