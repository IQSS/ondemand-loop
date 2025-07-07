# OnDemand Loop Guide

Welcome to the OnDemand Loop documentation.

**OnDemand Loop** is a companion application to **Open OnDemand**, designed to simplify the movement of research data between high-performance computing (HPC) clusters and remote repositories such as Dataverse, Figshare, or Zenodo.

The core goal of OnDemand Loop is to **lower the barrier for non-technical users** to interact with research data repositories. Following the Open OnDemand philosophy, it aims to provide a user-friendly interface for tasks that typically require complex command-line operations or custom scripts. Researchers can upload and download datasets to and from remote repositories directly from their HPC environment with minimal friction.

OnDemand Loop is **not a synchronization tool**. Instead, each **upload and download action is a discrete, immutable operation**. This means that if files are changed in either the repository or the local HPC system, users must **manually re-download or re-upload** to ensure that the latest versions are captured. This design prioritizes simplicity, reproducibility, and clear audit trails over automated syncing.

The application is built around a **pluggable connector framework**, with Dataverse as the reference implementation. Support for additional repositories can be added over time using the same connector architecture.

This guide introduces the entire application. Alongside the User Guide sections, it includes:

- **Admin Guide** – details on configuring and managing OnDemand Loop.
- **Installation Guide** – instructions to build and install the application as a passenger app on a server running Open OnDemand.
- **Development Guide** – how to run the app locally, make changes, understand the connector architecture, and create new connectors.

Together, these sections take you from basic usage through administration and development.
