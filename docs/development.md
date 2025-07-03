# Development Guide

## Run Dataverse locally
Follow the instructions to run a demo dataverse locally using Docker Compose:

https://guides.dataverse.org/en/latest/container/running/demo.html

## Install OnDemand Loop as a External Tool in Dataverse
Assuming that Dataverse is running locally in `localhost:8080` and this application is running in the Docker compose environment
`localhost:33000`, this will be the command to install the dataset External Tool manifest into Dataverse to
connect both applications:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "An external tool to Explore and Download dataset files in OOD",
  "toolName": "ondemand_loop_dataset_tool",
  "scope": "dataset",
  "types": [
    "explore"
  ],
  "toolUrl": "https://localhost:33000/pun/sys/loop/integrations/dataverse/external_tool/dataset",
  "httpMethod":"GET",
  "toolParameters": {
    "queryParameters": [
      {
        "dataverse_url": "{siteUrl}"
      },
      {
        "dataset_id": "{datasetPid}"
      },
      {
        "version": "{datasetVersion}"
      },
      {
        "locale":"{localeCode}"
      }
    ]
  }
}'
```

For production deployments, please change the Dataverse server location in the curl command and use the full path of the OOD
Passenger app in the `toolUrl` JSON property.

### Technical Notes
