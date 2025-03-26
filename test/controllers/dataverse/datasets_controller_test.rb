require "test_helper"

class Dataverse::DatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    @new_id = SecureRandom.uuid.to_s
    dataverse_metadata = Dataverse::DataverseMetadata.new
    dataverse_metadata.id = @new_id
    dataverse_metadata.hostname = 'localhost'
    dataverse_metadata.port = 443
    dataverse_metadata.scheme = 'https'
    dataverse_metadata.save
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def valid_json_body
    <<EOF
 {
  "status": "OK",
  "data": {
    "id": 6,
    "identifier": "FK2/GCN7US",
    "persistentUrl": "https://doi.org/10.5072/FK2/GCN7US",
    "protocol": "doi",
    "authority": "10.5072",
    "publisher": "Root",
    "publicationDate": "2025-01-23",
    "storageIdentifier": "local://10.5072/FK2/GCN7US",
    "datasetType": "dataset",
    "latestVersion": {
      "id": 3,
      "datasetId": 6,
      "datasetPersistentId": "doi:10.5072/FK2/GCN7US",
      "storageIdentifier": "local://10.5072/FK2/GCN7US",
      "versionNumber": 1,
      "versionMinorNumber": 0,
      "versionState": "RELEASED",
      "latestVersionPublishingState": "DRAFT",
      "lastUpdateTime": "2025-01-23T18:11:08Z",
      "releaseTime": "2025-01-23T18:11:08Z",
      "createTime": "2025-01-23T18:04:16Z",
      "publicationDate": "2025-01-23",
      "citationDate": "2025-01-23",
      "license": {
        "name": "CC0 1.0",
        "uri": "http://creativecommons.org/publicdomain/zero/1.0",
        "iconUri": "https://licensebuttons.net/p/zero/1.0/88x31.png"
      },
      "fileAccessRequest": true,
      "metadataBlocks": {
        "citation": {
          "displayName": "Citation Metadata",
          "name": "citation",
          "fields": [
            {
              "typeName": "title",
              "multiple": false,
              "typeClass": "primitive",
              "value": "sample dataset 3"
            },
            {
              "typeName": "author",
              "multiple": true,
              "typeClass": "compound",
              "value": [
                {
                  "authorName": {
                    "typeName": "authorName",
                    "multiple": false,
                    "typeClass": "primitive",
                    "value": "Admin, Dataverse"
                  },
                  "authorAffiliation": {
                    "typeName": "authorAffiliation",
                    "multiple": false,
                    "typeClass": "primitive",
                    "value": "Dataverse.org"
                  },
                  "authorIdentifierScheme": {
                    "typeName": "authorIdentifierScheme",
                    "multiple": false,
                    "typeClass": "controlledVocabulary",
                    "value": "ISNI"
                  }
                }
              ]
            },
            {
              "typeName": "datasetContact",
              "multiple": true,
              "typeClass": "compound",
              "value": [
                {
                  "datasetContactName": {
                    "typeName": "datasetContactName",
                    "multiple": false,
                    "typeClass": "primitive",
                    "value": "Admin, Dataverse"
                  },
                  "datasetContactAffiliation": {
                    "typeName": "datasetContactAffiliation",
                    "multiple": false,
                    "typeClass": "primitive",
                    "value": "Dataverse.org"
                  },
                  "datasetContactEmail": {
                    "typeName": "datasetContactEmail",
                    "multiple": false,
                    "typeClass": "primitive",
                    "value": "dataverse@mailinator.com"
                  }
                }
              ]
            },
            {
              "typeName": "dsDescription",
              "multiple": true,
              "typeClass": "compound",
              "value": [
                {
                  "dsDescriptionValue": {
                    "typeName": "dsDescriptionValue",
                    "multiple": false,
                    "typeClass": "primitive",
                    "value": "This is the description of the dataset"
                  }
                }
              ]
            },
            {
              "typeName": "subject",
              "multiple": true,
              "typeClass": "controlledVocabulary",
              "value": [
                "Agricultural Sciences"
              ]
            },
            {
              "typeName": "depositor",
              "multiple": false,
              "typeClass": "primitive",
              "value": "Admin, Dataverse"
            },
            {
              "typeName": "dateOfDeposit",
              "multiple": false,
              "typeClass": "primitive",
              "value": "2025-01-23"
            }
          ]
        }
      },
      "files": [
        {
          "label": "screenshot.png",
          "restricted": false,
          "version": 1,
          "datasetVersionId": 3,
          "dataFile": {
            "id": 7,
            "persistentId": "",
            "filename": "screenshot.png",
            "contentType": "image/png",
            "friendlyType": "PNG Image",
            "filesize": 272314,
            "storageIdentifier": "local://1949456747f-8c3ea98ea335",
            "rootDataFileId": -1,
            "md5": "13035cba04a51f54dd8101fe726cda5c",
            "checksum": {
              "type": "MD5",
              "value": "13035cba04a51f54dd8101fe726cda5c"
            },
            "tabularData": false,
            "creationDate": "2025-01-23",
            "publicationDate": "2025-01-23",
            "fileAccessRequest": true
          }
        }
      ]
    }
  }
}
EOF
  end

  test "should redirect to root path after not finding a dataverse_metadata" do
    get view_dataverse_dataset_url("random", "random_id")
    assert_redirected_to downloads_path
    assert_equal "Dataverse host metadata not found", flash[:error]
  end

  test "should redirect to root path after not finding a dataset" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to downloads_path
    assert_equal "Dataset not found", flash[:error]
  end

  test "should display the dataset view with the file" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_id).returns(dataset)
    get view_dataverse_dataset_url(@new_id, dataset.data.id)
    assert_response :success
    assert_select "input[type=checkbox]", 1 # One file is displayed on the view
  end
end
