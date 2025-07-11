# Dataverse Integration

## Running Dataverse Locally

To experiment with the Dataverse connector you can run a demo Dataverse instance via Docker Compose. Follow the official instructions:
<https://guides.dataverse.org/en/latest/container/running/demo.html>

Once running, Dataverse will be available at `http://localhost:8080` with a built in admin account.

## Registering the External Tool

Loop integrates with Dataverse through the External Tools feature. Register the tool with a request like:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "An external tool to Explore and Download dataset files in OOD",
  "toolName": "ondemand_loop_dataset_tool",
  "scope": "dataset",
  "types": ["explore"],
  "toolUrl": "https://localhost:33000/pun/sys/loop/integrations/dataverse/external_tool/dataset",
  "httpMethod": "GET",
  "toolParameters": {
    "queryParameters": [
      {"dataverse_url": "{siteUrl}"},
      {"dataset_id": "{datasetPid}"},
      {"version": "{datasetVersion}"},
      {"locale": "{localeCode}"}
    ]
  }
}'
```

With the tool registered, open any dataset in the local Dataverse and choose **Explore in OOD** to launch Loop preloaded with that dataset.

## Testing

After starting both Loop and Dataverse locally, create a project in Loop and verify that dataset pages open correctly from Dataverse. Download a sample file to confirm that authentication and API access are working.
