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

1. From the Open OnDemand dashboard, use the **Files > OnDemand Loop** menu item (or its configured location) to launch the app,
   or go directly to: `https://<ood-server>/pun/sys/loop`  
   You can always return to the dashboard later by clicking the **Open OnDemand** link in the navigation bar.
2. Sign in using your regular Open OnDemand credentials.
3. Familiarize yourself with the navigation bar at the top:
     - **Projects**, **Downloads**, **Uploads**, and a **Repositories** drop-down appear from left to right.
     - On the far right you’ll see links to **Open OnDemand** (back to the main dashboard) and a **Help** drop-down with links to the **Guide** and **Sitemap**.
4. Just below the navigation menu, you’ll see the **application bar**. This bar is sticky — it stays visible at the top of the screen as you scroll.
     - On the left: a project selection drop-down to switch the active project, and a button to create a new one.
     - On the right: the **Explore** widget, where you can paste a DOI or repository URL to browse a dataset and download files into your project.
     - Next to the Explore widget, a **folder icon** opens the **Repository Activity** window, giving you quick access to datasets you’ve recently explored.
5. Use the application bar to create your first project — it becomes the active project automatically so you can immediately begin adding downloads.

!!! info "Home Page Welcome Message"

    When you open the application on the **Home** page, a **welcome message** appears. It provides basic instructions and 
    a direct link back to this **Guide**.

!!! warning "Beta Notice:"

    *OnDemand Loop* is currently in **Beta**. You may encounter bugs, incomplete features, workflow changes without
    backward compatibility, and minor UI/UX inconsistencies. If issues arise after an update, use 
    **Help → Reset Application** to restore the application before reporting problems. We welcome
    [feedback and bug reports](https://github.com/IQSS/ondemand-loop/issues) to help us improve!

    Selecting **Help → Restart** restarts your Per User NGINX (PUN). All Passenger applications running on the PUN — including
    Loop and the Open OnDemand Dashboard — are terminated and will cold-start the next time you
    open them. The applications persist their state on disk, so you may lose only in-memory caches and experience
    a brief startup delay when they relaunch.

    Selecting **Help → Reset Application** does the same as **Restart**, restarting the PUN, and also removes all projects 
    and files metadata. This returns the application to a brand new status. Transferred files on disk and in remote 
    repositories will remain untouched. Reset Application flow is temporary and intended only for the Beta period.
 
