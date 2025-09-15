# Projects

In OnDemand Loop, a **project** is your workspace — a container that groups related downloads, uploads, and data organization tasks into a single context.
Projects help you manage your research data workflow in a structured way, whether you're retrieving datasets for analysis or preparing files for publication.

You can view and manage your projects by clicking on **Projects** in the navigation bar.

### Why Use Projects?

Projects are designed to:

- Organize research data movement by study, phase, or purpose
- Keep uploads and downloads clearly associated with specific goals
- Provide clean separation between different tasks, teams, or experiments
- Track file status, history, and local paths in one place

You can also use projects for short-lived or ad-hoc tasks — such as quickly downloading test data, replicating a publication, or staging files for upload — without affecting your main workflows.

### Creating and Managing Projects

- Click **Create Project** on the home page (or from the application bar) to start a new project.  
  OnDemand Loop assigns a randomly generated HPC-themed name, which you can rename at any time by clicking the pencil icon next to the title.
- Only **one project can be active at a time**.  
  Use the **pin icon** or the **project selection drop-down** in the application bar to set a project active. All new downloads will be assigned to the active project automatically.

!!! tip
    The **active project** determines where files are stored when you select them for download.  
    The application bar, visible on every page, makes it easy to confirm or change the active project without interrupting your workflow.  
    Always check that the correct project is selected before beginning to download files.


### What You Can Do With a Project

Selecting a project opens its **detail page**, where you can:

- **Edit project name**.
- **Review the status of downloads and uploads**, including progress and completion history.
- **Create upload bundles** linked to a specific remote dataset.
- **Stage files for upload** by selecting local files from the HPC filesystem to include in a bundle.
- **Explore project folders**, including the local workspace and the associated metadata directory, directly on the cluster.
- **View lifecycle events** using the **Events** button to see when the project was created, updated, or set as active.
- **Delete the project** when it is no longer needed.

!!! warning

    Downloading files is not triggered from the project detail page.
    To download data from a remote repository, use the **Explore** or **Repositories** features.  
    See the [Downloading Files](downloading_files.md) section for full instructions.

!!! note "Project ID and Deletion Behaviour"

    Each project is assigned a unique, randomly generated ID based on HPC-themed name.
    This ID appears in the URL and is used internally to reference the project.  
    **It cannot be changed** after creation.

    Deleting a project will remove it from the OnDemand Loop interface, but **does not delete** any associated files:
    
    - Downloaded files remain on disk.
    - Uploaded files remain in the remote repository.

    You can manually clean up downloaded data from disk if needed.

!!! note "Events"

    The **Events** view provides a chronological log of the project's history. Each entry records actions such as creation, name
    changes, and when the project was marked active, helping you track activity over time.

### Project Folder Structure

Each project has a dedicated location on the user's space on the HPC filesystem with two main folders:

#### Project Workspace Folder

This is the **working directory** for the project. It contains:

- All downloaded files from remote repositories with the relevant path if provided by the repository
- Subdirectories (if applicable) for organizing data by dataset or purpose

You can open the project workspace folder from the project detail page by clicking on the icon on the left of the project name.

#### Metadata Folder

This folder stores internal files used by OnDemand Loop to manage the project state, downloads, uploads and track activity:

- Project metadata
- Repository settings
- Download manifests
- Upload manifests

The metadata folder is useful for debugging or inspecting the internal state of the application.
You can open the project metadata directory directly from the project detail page by clicking on the icon on the top-right.

!!! note

    File and folder browsing is powered by the **Open OnDemand Files application**.  
    When you open a folder from the project detail page, it will launch the Files app in a new browser tab or window.  
    You can use it to move, rename, or inspect files directly on the cluster. When you're finished, close the window and return to the OnDemand Loop interface.

<pre><code># OnDemand LOOP Metadata Folder Structure

.loop_metadata/
├── projects/
│   └── experimental_processor_39/
│       ├── download_files/
│       ├── upload_bundles/
│       └── metadata.yml
├── repos/
│   └── repo_db.yml
├── detached.process.lock
├── launch_detached_process.log
└── user_settings.yml
</code></pre>
### Best Practices

- Use projects to mirror your research structure (e.g., by topic, grant, or publication).
- Create temporary projects for quick transfers or testing — you can delete them later without affecting stored data.
- Keep your workspace tidy by removing old projects you no longer need.
- Clean up files after deleting a project