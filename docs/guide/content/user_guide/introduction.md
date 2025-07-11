# Introduction

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) is a companion application for [**Open OnDemand**](https://openondemand.org) that organizes file transfers 
using **Projects**.
A **Project** groups related download requests and **Upload Bundles**, so you can keep track of all activity in one place.
**Projects** are created from the Home page and only one Project is active at a time.

Within a **Project** you can:

- **Explore remote repositories** by pasting a [DOI](https://www.doi.org) or a dataset URL on the **Explore** search bar, or by browsing the **Repositories** menu. Loop resolves the address and loads the appropriate **connector**. [**Dataverse**](https://dataverse.org) is included by default and [**Zenodo**](https://zenodo.org) can be enabled optionally.
- **Download files** from datasets. Selected files are added to the **Active Project** and transferred to your cluster workspace while progress appears under the Project or on the global **Downloads page**.
- **Create Upload Bundles** for sending data back to a repository. Provide the target dataset URL, supply an API key if required, and then choose local files for uploading.
- **Use the built-in file browser** to pick files from your HPC environment. You can navigate directories, drag and drop entries, or open the standard **OnDemand file app** for a folder.
- **Monitor transfer status** on each Project’s Downloads and Uploads tabs or on the aggregate pages that list tasks across all Projects, with automatic refresh and the option to cancel jobs.

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) performs discrete upload and download actions rather than continuous synchronization. If either the repository or your local files change, re-run the transfer to capture the updated versions.

The following pages in this guide explain each task in detail so you can confidently manage data transfers between your HPC cluster and supported repositories.
