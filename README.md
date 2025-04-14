# Dataverse for OnDemand

This project is an integration of Dataverse for Open OnDemand to allow managing the file transferring from
both applications. This software is intended to be run as a Passenger app in a Open OnDemand setup.

## 🚀 Getting Started

### Prerequisites
Ensure you have the following installed:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make` (usually pre-installed on Linux/macOS, Windows users may need to install it via WSL or Git Bash)


## 📦 Available commands

The following `make` commands are available to manage the application:

### Build and Install Dependencies
- **Build the Docker container to build the application:**
  ```sh
  make loop_docker_builder
  ```
- **Install dependencies and compile assets:**
  ```sh
  make loop_build
  ```

### Start and Stop Containers
- **Start the container in the background:**
  ```sh
  make loop_up
  ```
- **Stop the container:**
  ```sh
  make loop_down
  ```

### Debugging and Logs
- **View development logs for the OnDemand Loop application:**
  ```sh
  make logs
  ```
- **Open a Bash shell inside the OOD container running OOD and OnDemand Loop:**
  ```sh
  make bash
  ```


### Running Tests
- **Run tests using Minitest:**
  ```sh
  make test
  ```
  
## Start developing and running the application

To start developing or running the developer server, run the following commands:

```sh
make loop_build
```
To build the developer container image

```sh
make loop_up
```
To install all gem dependencies and build the assets

The application will be running under `https://localhost:33000/pun/sys/loop`

### Populate local environment with development data

to load the special project folder with sample files to view the application
with some data, run this task:

```sh
rake dev:populate
```

## Install External Tool in Dataverse

Assuming that Dataverse is running locally in `localhost:8080` and this application running standalone in
`localhost:3000`, this will be the command to install the dataset External Tool manifest into Dataverse to
connect both applications:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "A external tool to Explore datasets in OOD and download their files",
  "toolName": "dataverse_on_demand_dataset_tool",
  "scope": "dataset",  
  "types": [
    "explore"
  ],
  "toolUrl": "http://localhost:3000/integrations/dataverse/external_tool/dataset",
  "httpMethod":"GET",
  "toolParameters": {
    "queryParameters": [      
      {
        "datasetPid": "{datasetPid}"
      },
      {
        "datasetId": "{datasetId}"
      },
      {
        "locale":"{localeCode}"
      }
    ]
  },
  "allowedApiCalls": [    
    {
      "name":"getDatasetDetailsFromPid",
      "httpMethod":"GET",
      "urlTemplate":"/api/datasets/:persistentId/?persistentId={datasetPid}",
      "timeOut":270
    },
    {
      "name":"getDatasetDetails",
      "httpMethod":"GET",
      "urlTemplate":"/api/datasets/{datasetId}",
      "timeOut":270
    }
  ]
}'
```

For production deployments, please change the Dataverse server location in the curl command and use the full path of the OOD 
Passenger app in the `fullUrl` JSON property.


### Technical Notes
Adding vanilla JS to the app
app/javascript/collections_status_refresh.js

config/importmap.rb
pin "collections_status_refresh"
```erb
<script type="module" src="<%= asset_path('collections_status_refresh') %>"></script>
```

```javascript
import { cssBadgeForState } from "./utils"
  document.addEventListener("DOMContentLoaded", function () {
    console.log("JavaScript file loaded!");
    myFunction();
  });

  function myFunction() {
    console.log("MyFunction")
    setInterval(() => {
      console.log(cssBadgeForState('error'))
    }, loop_app_config.connector_status_poll_interval)
  }
```


