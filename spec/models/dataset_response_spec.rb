require 'rails_helper'

RSpec.describe DatasetResponse, type: :model do
  let(:valid_json_body) do
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

  let(:empty_json) { "{}" }
  let(:empty_string) { "" }

  let(:incomplete_json_body) do
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
    "datasetType": "dataset"
  }
}
EOF
  end

  describe DatasetResponse do
    describe "valid json" do
      subject(:dataset) { DatasetResponse.new(valid_json_body) }

      it "should parse the dataset body" do
        expect(dataset).to be_a(DatasetResponse)
      end

      it "parses the status correctly" do
        expect(dataset.status).to eq("OK")
      end

      it "creates a DatasetData object" do
        expect(dataset.data).to be_a(DatasetData)
      end

      describe DatasetData do
        subject(:dataset_data) { dataset.data }

        it "parses attributes correctly" do
          expect(dataset_data.id).to eq(6)
          expect(dataset_data.identifier).to eq("FK2/GCN7US")
          expect(dataset_data.persistent_url).to eq("https://doi.org/10.5072/FK2/GCN7US")
          expect(dataset_data.publisher).to eq("Root")
          expect(dataset_data.publication_date).to eq("2025-01-23")
          expect(dataset_data.dataset_type).to eq("dataset")
        end

        it "creates a DatasetVersion object" do
          expect(dataset_data.latest_version).to be_a(DatasetVersion)
        end
      end

      describe DatasetVersion do
        subject(:dataset_version) { dataset.data.latest_version }

        it "parses attributes correctly" do
          expect(dataset_version.id).to eq(3)
          expect(dataset_version.version_number).to eq(1)
          expect(dataset_version.version_state).to eq("RELEASED")
        end

        it "creates a License object" do
          expect(dataset_version.license).to be_a(License)
        end

        it "creates an array of DatasetFile objects" do
          expect(dataset_version.files).to all(be_a(DatasetFile))
        end

        it "has the right amount of files" do
          expect(dataset_version.files.size).to be(1)
        end
      end

      describe License do
        subject(:license) { dataset.data.latest_version.license }

        it "parses attributes correctly" do
          expect(license.name).to eq("CC0 1.0")
          expect(license.uri).to eq("http://creativecommons.org/publicdomain/zero/1.0")
          expect(license.icon_uri).to eq("https://licensebuttons.net/p/zero/1.0/88x31.png")
        end
      end

      describe DatasetFile do
        subject(:dataset_file) { dataset.data.latest_version.files.first }

        it "parses attributes correctly" do
          expect(dataset_file.label).to eq("screenshot.png")
          expect(dataset_file.restricted).to be false
        end

        it "creates a DataFile object" do
          expect(dataset_file.data_file).to be_a(DataFile)
        end
      end

      describe DataFile do
        subject(:data_file) { dataset.data.latest_version.files.first.data_file }

        it "parses attributes correctly" do
          expect(data_file.id).to eq(7)
          expect(data_file.filename).to eq("screenshot.png")
          expect(data_file.content_type).to eq("image/png")
          expect(data_file.filesize).to eq(272314)
          expect(data_file.md5).to eq("13035cba04a51f54dd8101fe726cda5c")
        end
      end
    end

    describe "empty json" do
      subject(:dataset) { DatasetResponse.new(empty_json) }

      it "should raise an error" do
        expect { dataset.status }.to raise_error(NoMethodError)
        expect { dataset.data }.to raise_error(NoMethodError)
      end
    end

    describe "empty string" do
      subject(:dataset) { DatasetResponse.new(empty_string) }

      it "should raise an error" do
        expect { dataset }.to raise_error(JSON::ParserError)
      end
    end

    describe "incomplete json" do
      subject(:dataset) { DatasetResponse.new(incomplete_json_body) }

      it "should raise an error" do
        expect { dataset }.to raise_error(NoMethodError)
      end
    end

  end
end
