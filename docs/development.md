# Development Guide

## Install OnDemand Loop as a External Tool in Dataverse
Assuming that Dataverse is running locally in `localhost:8080` and this application is running in the Docker compose environment
`localhost:33000`, this will be the command to install the dataset External Tool manifest into Dataverse to
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
  "toolUrl": "http://localhost:33000/pun/sys/loop/integrations/dataverse/external_tool/dataset",
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
