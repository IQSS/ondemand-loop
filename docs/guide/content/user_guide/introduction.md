# Introduction

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) is a companion application for [**Open OnDemand**](https://openondemand.org) that streamlines file transfers 
using **Projects**.
A **Project** groups related download requests and **Upload Bundles**, helping you organize and monitor all activity in one place.
**Projects** are created from the Home page, and only one Project is active at a time.

Within a **Project** you can:

- **Explore remote repositories** by pasting a [DOI](https://www.doi.org) or a dataset URL into the **Explore** search bar, or by browsing the **Repositories** menu. Loop resolves the address and loads the appropriate **connector**. [**Dataverse**](https://dataverse.org) is supported by default and [**Zenodo**](https://zenodo.org) can be enabled optionally.
- **Download files** from datasets. Selected files are added to the **Active Project** and transferred to your cluster workspace. Transfer progress is shown under the Project or on the global **Downloads page**.
- **Create Upload Bundles** to send data back to a repository. Simply provide the target dataset URL, include an API key if required, and select local files for uploading.
- **Use the built-in file browser** to select files from your HPC environment. You can navigate directories, drag and drop entries, or open the standard **OnDemand file app** for a folder.
- **Monitor transfer status** via each Project’s Downloads and Uploads tabs, or on the aggregate pages that list tasks across all Projects, with automatic refresh and the option to cancel jobs.

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) performs discrete upload and download actions rather than continuous synchronization. If either the repository or your local files change, re-run the transfer to capture the latest versions.

The following pages in this guide provide detailed explanations of each task, enabling you to confidently manage data transfers between your HPC cluster and supported repositories.

# Getting Started

1. Open your web browser and navigate to `https://<ood-server>/pun/sys/loop`.
2. Sign in using your regular Open OnDemand credentials.
3. Familiarize yourself with the navigation bar:
    - **Projects**, **Downloads**, **Uploads**, and a **Repositories** drop-down (for Dataverse and optional Zenodo) appear from left to right.
    - The **Explore** link toggles a bar where you can paste a DOI or repository URL.
    - On the far right you’ll see links to **Open OnDemand** (which returns you to the main dashboard) and **Restart**.
4. The first time you visit, create project so that you can immediately begin adding downloads.
5. From the Open OnDemand dashboard, use the **Files > OnDemand Loop** menu item (or its configured location) to launch this app. When you’re done in Loop, click the **Open OnDemand** link in the navigation bar to go back to the dashboard.

