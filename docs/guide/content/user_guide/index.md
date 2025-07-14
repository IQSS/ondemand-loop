# Introduction

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) helps you manage the movement of **research data** between your HPC environment and remote repositories through an intuitive, project-based workflow.
It is designed to support typical steps in the research data lifecycle—such as retrieving data for analysis or preparing results for publication—by streamlining both downloads and uploads.

You begin by creating a **Project**, which acts as your workspace for organizing related data transfer activities.
The project becomes the context for all actions performed through the user interface.

Each project has its own:

- **Working directory** – where downloaded files are saved. This keeps files organized and isolated by project, making them easy to find and manage.
- **Metadata directory** – where the application stores internal data such as download history, upload collection definitions, and the Project’s current state. This allows OnDemand Loop to track progress, resume operations, and display status accurately.

Having an active Project enables you to:

- **Download files** from supported repositories. These downloads are saved into the project working directory and automatically tracked by the application.
- **Create upload collections**, which group references to local files to be uploaded to a single remote repository. Uploads are queued, monitored, and managed directly from the interface.

The interface is designed to guide you through these workflows with minimal setup, making it easy to track progress, review status, and repeat actions when needed.

OnDemand Loop is **not a synchronization tool**. Instead, each **upload and download action is a discrete, immutable operation**. This means that if files are changed in either the repository or the local HPC system, users must **manually re-download or re-upload** to ensure that the latest versions are captured. This design prioritizes simplicity, reproducibility, and clear audit trails over automated syncing.

Every transfer runs as a background job, allowing work to continue even if you close your browser session.
Built‑in repository connectors handle the details of each repository’s API, letting you browse datasets, pick local files, and watch the job status from the web interface.

### Getting Started

1. Open your web browser and navigate to `https://<ood-server>/pun/sys/loop`.
2. Sign in using your regular Open OnDemand credentials.
3. Familiarize yourself with the navigation bar:
    - **Projects**, **Downloads**, **Uploads**, and a **Repositories** drop-down appear from left to right.
    - The **Explore** link toggles a bar where you can paste a DOI or repository URL.
    - On the far right you’ll see links to **Open OnDemand** (which returns you to the main dashboard) and **Restart**.
4. The first time you visit, create project so that you can immediately begin adding downloads.
5. From the Open OnDemand dashboard, use the **Files > OnDemand Loop** menu item (or its configured location) to launch this app. When you’re done in Loop, click the **Open OnDemand** link in the navigation bar to go back to the dashboard.
