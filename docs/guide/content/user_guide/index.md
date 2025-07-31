# Introduction

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) helps you manage the movement of **research data** between your HPC environment and remote repositories through an intuitive, project-based workflow.
It is designed to support typical steps in the research data lifecycle — such as retrieving data for analysis or preparing results for publication — by streamlining both downloads and uploads.

You begin by creating a **project**, which acts as your workspace for organizing related data transfer activities.
The project becomes the context for all actions performed through the user interface.

Each project has its own:

- **Workspace directory** – where downloaded files are saved. This keeps files organized and separated by project, making them easy to find and manage.
- **Metadata directory** – where the application stores internal data such as download history, upload bundle definitions, and the project’s current state. This allows OnDemand Loop to track progress, resume operations, and display status accurately.

Having an active project enables you to:

- **Download files** from supported repositories. These downloads are saved into the project working directory and automatically tracked by the application.
- **Create upload bundles**, which group references to local files to be uploaded to a single remote repository. Uploads are queued, monitored, and managed directly from the interface.

The interface is designed to guide you through these workflows with minimal setup, making it easy to track progress, review status, and repeat actions when needed.

!!! note

    OnDemand Loop is **not a synchronization tool**. Instead, each **upload and download action is a discrete operation**.
    This means that if files are changed in either the repository or the local HPC system, users must **manually re-download or re-upload** to ensure that the latest versions are captured.
    This design prioritizes simplicity, reproducibility, and clear audit trails over automated syncing.


Every transfer runs as a background job, allowing work to continue even if you close your browser session.
Built‑in repository connectors handle the details of each repository’s API, letting you browse datasets, pick local files, and watch the job status from the web interface.

### Getting Started

1. Open your web browser and navigate to `https://<ood-server>/pun/sys/loop`.
2. Sign in using your regular Open OnDemand credentials.
3. Familiarize yourself with the navigation bar:
    - **Projects**, **Downloads**, **Uploads**, and a **Repositories** drop-down appear from left to right.
    - On the far right you’ll see links to **Open OnDemand** (which returns you to the main dashboard) 
    - There is also a **Help** dropdown where you can find a link to this **Guide**, the **Sitemap** and **Restart**.
4. The first time you visit, create a project and make it active, so that you can immediately begin adding downloads.
5. Locate the always-visible **Explore** bar near the top of the screen. Paste a DOI or repository URL (e.g., from Dataverse or Zenodo) into this field to browse the dataset contents and selectively download files to your local project directory.
6. From the Open OnDemand dashboard, use the **Files > OnDemand Loop** menu item (or its configured location) to launch this app. When you’re done in OnDemand Loop, click the **Open OnDemand** link in the navigation bar to go back to the dashboard.
