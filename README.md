<div style="width: 100%; background-color: black; padding: 20px 0; text-align: center;">
  <img src="docs/guide/content/assets/banner.png" alt="OnDemand Loop Logo" style="max-width: 300px;">
</div>

![Line coverage](docs/badges/coverage-line.svg)
![Branch coverage](docs/badges/coverage-branch.svg)

# OnDemand Loop
Welcome to the OnDemand Loop documentation.

[**OnDemand Loop**](https://github.com/IQSS/ondemand-loop) is a companion application to [**Open OnDemand**](https://openondemand.org), designed to streamline the movement of research data between high-performance computing (HPC) clusters and remote repositories such as [**Dataverse**](https://dataverse.org), or [**Zenodo**](https://zenodo.org).

The core goal of OnDemand Loop is to **lower the barrier for non-technical users** to interact with research data repositories. Following the Open OnDemand philosophy, it aims to provide a user-friendly interface for tasks that typically require complex command-line operations or custom scripts. Researchers can upload and download datasets to and from remote repositories directly from their HPC environment with minimal friction.

> ⚠️ **Beta Notice**
>
> *OnDemand Loop* is currently in **Beta** status. While we strive to provide a stable experience, please be aware of the following:
>
> - You may encounter occasional bugs or incomplete features.
> - User interface and workflow changes may occur without backward compatibility guarantees.
> - Minor UI/UX inconsistencies are expected as the product evolves.
> - We welcome feedback and bug reports to help us improve!

For complete documentation please see the [OnDemand Loop Guide](https://iqss.github.io/ondemand-loop/).

### License
This project is licensed under the [MIT License](LICENSE).

## 🚀 Deployment
See the [Installation Guide](https://iqss.github.io/ondemand-loop/installation/) for deployment instructions.

Refer to the [Admin Guide](https://iqss.github.io/ondemand-loop/admin/) for details on configuring the application using environment variables and YAML configuration files.

### System Requirements
See the [Installation Guide system requirements section](https://iqss.github.io/ondemand-loop/installation/#system-requirements).

### Installation
Follow the steps in the [Installation Guide](https://iqss.github.io/ondemand-loop/installation/#building-the-application) to install OnDemand Loop.

## 🛠️ Development
Refer to the [Development Guide](https://iqss.github.io/ondemand-loop/development_guide/) for running the application locally and contributing changes.

### 🚀 Quick Start
To quickly set up and run OnDemand Loop in a local development environment,
follow the steps below or refer to the [Quick Start section of the Development Guide](https://iqss.github.io/ondemand-loop/development_guide/#quick-start).

```sh
make loop_build
make loop_up
```

Once the containers are running, navigate to the application URL and log in with the local test credentials:

```sh
https://localhost:33000/pun/sys/loop

Username: ood
Password: ood
```


## ⚙️ Available Make Commands
A list of `make` commands is maintained in the [Development Guide](https://iqss.github.io/ondemand-loop/development_guide/local_environment/#make-commands).

---

<sub>This project has been funded by [FAS-HUIT Project Review Board (PRB) initiative](https://adminops.fas.harvard.edu/FAS-HUIT-PRB).</sub>