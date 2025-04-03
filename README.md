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

### Start and Stop Containers
- **Start the container in the background:**
  ```sh
  make up
  ```
- **Stop the container:**
  ```sh
  make down
  ```
- **Restart the container:**
  ```sh
  make restart
  ```

### Build and Install Dependencies
- **Build or rebuild the container:**
  ```sh
  make build
  ```
- **Install dependencies with `bundle install`:**
  ```sh
  make install
  ```

### Running the Application
- **Start the Rails server:**
  ```sh
  make server
  ```
  The server will be accessible at `http://localhost:3000`.
- **Start the Rails server in production mode:**
  ```sh
  make prod_server
  ```

### Debugging and Logs
- **View development logs for the Rails application:**
  ```sh
  make logs
  ```
- **Open a Bash shell inside the Rails app container:**
  ```sh
  make bash
  ```
- **Open a Rails console inside the app container:**
  ```sh
  make console
  ```

### Running Tests
- **Run tests using Minitest:**
  ```sh
  make tests
  ```
  
## Start developing and running the application

To start developing or running the developer server, run the following commands:

```sh
make build
```
To build the developer container image

```sh
make install
```
To install all gem dependencies with Bundle

```sh
make server
```
To run the developer Rails server and see the application in `localhost:3000`

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


