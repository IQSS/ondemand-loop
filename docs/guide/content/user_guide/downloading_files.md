# Downloading Files

OnDemand Loop allows you to download files from different repositories into the HPC environment.  
After locating a dataset (via DOI, URL, or browsing), you can download specific files into your active project.

---

### How to Download Files

1. **Select files**  
   On the dataset page, use the checkboxes to select the files you want to download.
2. **Add to project**  
   When at least one file is selected, the **Add Files to New Project** or **Add Files to Active Project** button becomes enabled. Clicking it schedules the selected files for download to a project.
    - The text of the button depends on the presence of an active project in the application.
    - If no Project is active, OnDemand Loop automatically creates a new one everytime files are added.
    - To make all downloads go to the same specific project, set that Project as Active.
3. **Track progress**  
   Monitor download activity in two places:
    - The **Downloads** tab of the selected project (shows only that project's files)
    - The **Downloads** page (global view across all projects)

!!! warning

    File selections are **page-based** and do not persist across pagination or page reloads.
    If you navigate away or move to another page of results, your current selections will be lost.
    To download files from multiple pages, select and add files **one page at a time** to your project.

---

### Project Detail Page – Downloads Tab

Each project detail page includes a **Downloads** tab showing its associated download requests.
The data is displayed in a table format, where each row represents a file and shows key metadata.

!!! warning

    Project list view displays a summary of the downloads. The full information of the dowloaded files is displayed
    on the Project detail page.

#### Downloads Tab Header

At the top of the Downloads tab, a summary panel displays key information about the project's download activity:

- **Download Folder Path**  
  Shows the workspace folder in the local filesystem, where downloaded files for this project are stored.
  You can click the folder icon to open it using the Open OnDemand Files app.

- **Status Summary Counters**  
  A visual breakdown of all download requests associated with this project:
    - **Pending** – Files waiting to be processed.
    - **Completed** – Successfully downloaded files.
    - **Cancelled** – Downloads that were manually cancelled before completion.
    - **Error** – Downloads that failed due to network, a repository issue or a failed checksum verification.
    - **Total** – The total number of download requests.

The large circular indicator highlights the **percentage of completed downloads**, helping you quickly assess progress at a glance.


#### Metadata Fields

**Scheduled Date:** The date the file was selected for download.  
**Repository Badge:** Identifies the source repository. Links to the dataset view in OnDemand Loop.  
**Filename:** The filename and relative path created by OnDemand Loop in the project workspace.  
**Size:** The file size reported by the remote repository.  
**Status:** The current download state. One of: `pending`, `downloading`, `success`, `error`, `cancelled`.  
**Completed Date:** The date the system finished processing the file (successfully or not).  
**Delete Action:** Removes the file from the project’s list in the UI.  

!!! note
    
    This view does **not auto-refresh**. Reload manually to see updates.

---

### Global Downloads Page

The **Downloads** page provides a real-time view of all download tasks across all projects.
It is updated automatically every **5 seconds** and reflects the most recent activity at the top.

#### Downloads Page Header

At the top of the global **Downloads** page, a summary panel displays the current system-wide download state and job activity.

- **Job Status Icon**  
  Displays a **play** or **pause** icon indicating whether a background job is actively downloading files:
    - **Play icon** – A processing job is currently running.
    - **Pause icon** – No download job is currently active.

- **Start Time**  
  Shows the **timestamp** of when the most recent background job began processing downloads.

- **Elapsed Time**  
  Indicates how long the job took to process the files currently shown on the page.

- **Status Summary Counters**  
  A live snapshot of all downloads:
    - **Pending** – Files queued for download but not yet started.
    - **In Progress** – Files currently being downloaded.
    - **Completed** – Successfully downloaded files.
    - **Total** – The total number of files in the current job.

#### Metadata Fields

**Link to File Location:** A direct link to the downloaded file on the HPC filesystem (within the project workspace).  
**Scheduled Date:** The date and time the file was added to the download queue.  
**Repository Badge:** Shows the source repository. Helps identify origin at a glance.  
**Project Name:** The project the file belongs to. Click to open the project detail page.  
**Filename:** The name and relative path assigned to the file by OnDemand Loop.  
**Size:** The file size as reported by the remote repository.  
**Progress Bar:** A visual indicator shown when status is `downloading`. Updates every 5 seconds.  
**Status:** The current download state. One of: `pending`, `downloading`, `success`, `error`, `cancelled`.  
**Cancel Action:** Lets you cancel files in `pending` or `downloading` state. Not available once completed.  

#### Behavior

- Files are automatically **queued** when system limits for concurrent downloads are reached (`pending` state).
- Downloads in progress show a **progress bar**, updated every 5 seconds.
- Completed downloads remain visible for **24 hours** in the global view.
- After that, they are only listed in the project's Downloads tab.
- The list is sorted in this order:
    1. Active downloads (`downloading`)
    2. Pending downloads
    3. Completed downloads (most recent first)

!!! warning

    Files cannot be deleted directly from the global **Downloads** page.
    To remove a file from the UI, navigate to its project and use the **Delete** action in the **Downloads** tab.
    You can quickly access the project detail page by clicking on the project name in the table.

---

### Duplicate Downloads

If the same file is added to a project more than once, OnDemand Loop will download it again using a modified filename:
<pre><code>original_file.csv
original_file_01.csv
original_file_02.csv
</code></pre>


Each version is treated as a separate task and stored independently.

---

### Checksum Verification

After each file is downloaded, OnDemand Loop automatically verifies its integrity using a checksum provided by the remote repository.  
If the verification fails, the file is marked with an **`error`** status, even if the download appears to have completed successfully.

This ensures that only fully intact and verified files are considered valid and usable.

---

### Best Practices

- Always check the **active project** before selecting files — downloads are assigned automatically.
- Use the **global Downloads page** to monitor multiple datasets or repositories.
- If a file is no longer needed, cancel it before it starts downloading to free system resources.
- Use the **project detail page** for cleaning up or reviewing file history.

!!! note "No automatic retries"

    No automatic retries are performed for failed downloads. You can reselect and add the file again manually if needed.
    You can quickly access the file dataset page by clicking on the file reposiory badge in the **Downloads** tab
