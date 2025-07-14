# 
<style>
.md-content h1:first-of-type {
  display: none;
}
</style>

<div class="d-flex flex-wrap align-items-end w-100 text-start">
  <img
    src="assets/banner_black.png"
    alt="OnDemand Loop Banner"
    class="me-2"
    style="max-width: 100%;
           height: 150px;"
  >
  <h2 class="m-0" style="font-size: 3rem; line-height: 1;">
    Guide
  </h2>
</div>

Welcome to the OnDemand Loop documentation.

**OnDemand Loop** is a companion application to **Open OnDemand**, designed to simplify the movement of research data between high-performance computing (HPC) clusters and remote repositories such as Dataverse, Figshare, or Zenodo.

The core goal of OnDemand Loop is to **lower the barrier for non-technical users** to interact with research data repositories. Following the Open OnDemand philosophy, it aims to provide a user-friendly interface for tasks that typically require complex command-line operations or custom scripts. Researchers can upload and download datasets to and from remote repositories directly from their HPC environment with minimal friction.

OnDemand Loop is **not a synchronization tool**. Instead, each **upload and download action is a discrete, immutable operation**. This means that if files are changed in either the repository or the local HPC system, users must **manually re-download or re-upload** to ensure that the latest versions are captured. This design prioritizes simplicity, reproducibility, and clear audit trails over automated syncing.

The application is built around a **extensible connector framework**, with Dataverse as the reference implementation. Support for additional repositories can be added over time using the same connector architecture.

At the center of Loop are **Projects**. A project groups all of your download requests and upload bundles so you can monitor progress in one place. Every transfer runs as a background job through the HPC scheduler, allowing work to continue even if you close your browser session. Built‑in connectors handle the details of each repository’s API, letting you browse datasets, pick local files, and watch the job status from the web interface.

This guide introduces the entire application. It is divided into the following guides:

- [**User Guide**](user_guide/introduction.md) – how to use the application to transfer files.
- [**Admin Guide**](admin.md) – details on configuring and managing OnDemand Loop.
- [**Installation Guide**](installation.md) – instructions to build and install the application as a Passenger app on a server running Open OnDemand.
- [**Development Guide**](development_guide/index.md) – how to run the application locally, make changes, understand the connector architecture, and create new connectors.

Together, these sections take you from basic usage through administration and development.
