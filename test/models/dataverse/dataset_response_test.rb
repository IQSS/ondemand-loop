require "test_helper"

class Dataverse::DatasetResponseTest < ActiveSupport::TestCase
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
                    "value": "asdsdsadadsadsadsadd"
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

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  def incomplete_json_body
    <<-EOF
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
        "datasetType": "dataset"
      }
    }
    EOF
  end

  test "valid json parses dataset response" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    assert_instance_of Dataverse::DatasetResponse, dataset
    assert_equal "OK", dataset.status
    assert_instance_of Dataverse::DatasetResponse::Data, dataset.data
  end

  test "valid json parses dataset response data" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    data = dataset.data
    assert_equal 6, data.id
    assert_equal "FK2/GCN7US", data.identifier
    assert_equal "https://doi.org/10.5072/FK2/GCN7US", data.persistent_url
    assert_equal "Root", data.publisher
    assert_equal "2025-01-23", data.publication_date
    assert_equal "dataset", data.dataset_type
  end

  test "valid json parses dataset response latest version" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    version = dataset.data.latest_version
    assert_instance_of Dataverse::DatasetResponse::Data::Version, version
    assert_equal 3, version.id
    assert_equal 1, version.version_number
    assert_equal "RELEASED", version.version_state
  end

  test "valid json parses dataset response license" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    license = dataset.data.latest_version.license
    assert_instance_of Dataverse::DatasetResponse::Data::Version::License, license
    assert_equal "CC0 1.0", license.name
    assert_equal "http://creativecommons.org/publicdomain/zero/1.0", license.uri
    assert_equal "https://licensebuttons.net/p/zero/1.0/88x31.png", license.icon_uri
  end

  test "valid json parses dataset response files" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    version = dataset.data.latest_version

    assert_equal 1, version.files.size
    version.files.each { |file| assert_instance_of Dataverse::DatasetResponse::Data::Version::DatasetFile, file }

    file = version.files.first
    assert_equal "screenshot.png", file.label
    refute file.restricted
    assert_instance_of Dataverse::DatasetResponse::Data::Version::DatasetFile::DataFile, file.data_file

    data_file = file.data_file
    assert_equal 7, data_file.id
    assert_equal "screenshot.png", data_file.filename
    assert_equal "image/png", data_file.content_type
    assert_equal 272314, data_file.filesize
    assert_equal "13035cba04a51f54dd8101fe726cda5c", data_file.md5
  end

  test "empty json raises error" do
    assert_raises(NoMethodError) { Dataverse::DatasetResponse.new(empty_json) }
  end

  test "empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { Dataverse::DatasetResponse.new(empty_string) }
  end

  test "incomplete json raises NoMethodError when accessing missing data" do
    assert_raises(NoMethodError) { Dataverse::DatasetResponse.new(incomplete_json_body) }
  end
end
