# Introduction

**OnDemand Loop** is a companion application for Open OnDemand that organizes transfers using **projects**.
A project groups related download requests and upload bundles so you can keep track of all activity in one place.
Projects are created from the home page and only one project is active at a time.

Within a project you can:

- **Explore remote repositories** by pasting a DOI or URL or by browsing the **Repositories** menu. Loop resolves the address and loads the appropriate connector—Dataverse is included by default and Zenodo can be enabled optionally.
- **Download files** from datasets. Selected files are added to the active project and transferred to your cluster workspace while progress appears under the project or on the global Downloads page.
- **Create upload bundles** for sending data back to a repository. Provide the target dataset URL, supply an API key if required, and then choose local files for uploading.
- **Use the built-in file browser** to pick files from your HPC environment. You can navigate directories, drag and drop entries, or open the standard OnDemand file app for a folder.
- **Monitor transfer status** on each project’s Downloads and Uploads tabs or on the aggregate pages that list tasks across all projects, with automatic refresh and the option to cancel jobs.

OnDemand Loop performs discrete upload and download actions rather than continuous synchronization. If either the repository or your local files change, re-run the transfer to capture the updated versions.

The following pages in this guide explain each task in detail so you can confidently manage data transfers between your HPC cluster and supported repositories.
