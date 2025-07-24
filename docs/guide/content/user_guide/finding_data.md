# Finding Data

One of the first steps when working on a project in OnDemand Loop is locating the right dataset — typically for downloading data into your project.
The application supports two ways of finding datasets from remote repositories:

1. **Using the repository website and pasting a URL or DOI in Loop**  
   Best for advanced users who know where the dataset is located.
2. **Browsing and searching directly inside the OnDemand Loop interface**  
   Ideal for new users or those still exploring available datasets.

!!! note "Supported Repositories"

    OnDemand Loop currently supports two repository connectors: **Dataverse** and **Zenodo** ([contributions are welcome to add more](../development_guide/contributing.md)).
    Only **public datasets** are supported for download at this time.  
    Support for **[draft datasets](https://github.com/IQSS/ondemand-loop/issues/310)**, and **private access** is planned for future releases.

---

### Choosing the Best Approach

| Method                          | Best For                           | Benefits                                             |
|---------------------------------|------------------------------------|------------------------------------------------------|
| **Paste URL or DOI**            | Experienced users, known datasets | Fast and direct. Leverages repository search tools.  |
| **Browse within OnDemand Loop** | New users, exploratory workflows   | Fully integrated. No need to leave the app.          |

---

### Exploring Remote Repositories

There are two ways to explore datasets from a remote repository when downloading data:

#### 1. Paste a Repository URL or DOI

If you already know the dataset you need, this is the fastest option:

1. Visit the repository’s website.
2. Find the dataset and copy its URL or DOI, such as:
    - A DOI:  
      `https://doi.org/10.7910/DVN/MYSRMN`
    - A full URL from a repository:  
      `https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/MYSRMN`  
      `https://zenodo.org/record/1234567`
3. In the application, click **Explore** in the top navigation bar.
4. Paste the URL or DOI and click **Connect**.

OnDemand Loop will:

- Automatically detect the repository (based on the address)
- Invoke the appropriate connector
- Display the dataset’s metadata and file list

!!! tip

    This method is especially efficient if you're working from a publication, citation, or already bookmarked dataset.

---

#### 2. Browse and Search Within OnDemand Loop

If you prefer an integrated experience or are still exploring:

1. Click on the **Repositories** menu in the app.
2. Choose a supported remote repository, like **Dataverse** or **Zenodo**.
3. In case of the existence of multiple repository installations, select the desired one.
4. Use the built-in search to look for datasets.
5. Navigate the results and select a dataset to explore.

Once a dataset is selected, OnDemand Loop presents its metadata and file listing so you can choose what to download into your project.

!!! note
    
    Each connector uses the repository’s public API. Features such as search, filters, and metadata previews may vary slightly.

### Launching from Dataverse

If the administrator of your Dataverse installation has configured OnDemand Loop as an **External Tool**, you can launch the application directly from the dataset page.

- Open a dataset in a Dataverse repository.
- Click the **Access Dataset** dropdown.
- Select **Explore in OnDemand Loop**.

This will open the OnDemand Loop interface with the dataset preloaded and ready for browsing or download.

!!! note "External Tools"
    
    This feature is only available for **Dataverse** and depends on the repository admin having enabled it. If you don't see the option, contact your Dataverse administrator.
    For Dataverse administrators: follow the instructions on how to configure [Dataverse external tools](../development_guide/dataverse_integration.md)

---
