# Upload File Selector

The **Upload File Selector** opens when you click **Add Files** on an upload bundle tab.  
It allows you to browse your HPC filesystem and choose the files or folders you want to upload.

The selector temporarily splits the upload bundle tab into two areas:

- The top **Drop Files Here** area for drag-and-drop selection
- The bottom **File Browser** area for navigating and selecting items

---

### Selecting Files and Folders

- You can **select both files and folders**.
- **Double-click** a file to stage it for upload, or **drag and drop** it into the **Drop Files Here** area (keyboard is also supported).
- To select a **folder**, use drag and drop only. All files inside the folder (including subfolders) will be recursively added.
- When uploading a folder, the upload metadata is automatically configured to preserve the relative path structure in the remote repository.

---

### Navigating the Filesystem

- Use **single-click** to enter a folder.
- To go up one level, click the `.. (Parent folder)` entry at the top of the list.
- Use the **breadcrumb path** displayed in the action bar to jump to any parent directory by clicking on its name.
- Click the **pencil icon** to manually edit the path.
- Click **Home** to return to your home directory.
- Alternatively the user can rely on the keyboard.

---

### Action Bar Controls

At the top of the selector, you’ll find the following controls:

- **Breadcrumb Path** – Shows the current directory; each segment is clickable.
- **Edit Path (Pencil Icon)** – Manually enter a path to jump to.
- **Home** – Returns to your home directory.
- **Open in OnDemand** – Launches the current folder in the standard Open OnDemand Files app for advanced file management.
- **Close** – Closes the file selector. You can also close it by clicking **Add Files** again (acts as a toggle).

---

!!! note

    - You can **drag files or folders from the browser listing** into the drop zone.
    - Folder uploads will maintain relative path structure in the final upload payload.
    - The file selector does **not** auto-refresh after external file operations
    - Use the Open in OnDemand Files app option for more advanced actions.
