module Dataverse
  class CreateDatasetRequest
    attr_accessor :title, :description, :author, :contact_email, :subjects

    def initialize(title:, description:, author:, contact_email:, subjects:)
      @title = title
      @description = description
      @author = author
      @contact_email = contact_email
      @subjects = subjects
    end

    def to_body
      {
        datasetVersion: {
          metadataBlocks: {
            citation: {
              fields: [
                {
                  value: title,
                  typeClass: "primitive",
                  multiple: false,
                  typeName: "title"
                },
                {
                  value: [
                    {
                      authorName: {
                        value: author,
                        typeClass: "primitive",
                        multiple: false,
                        typeName: "authorName"
                      }
                    }
                  ],
                  typeClass: "compound",
                  multiple: true,
                  typeName: "author"
                },
                {
                  value: [
                    {
                      datasetContactEmail: {
                        value: contact_email,
                        typeClass: "primitive",
                        multiple: false,
                        typeName: "datasetContactEmail"
                      },
                      datasetContactName: {
                        value: author,
                        typeClass: "primitive",
                        multiple: false,
                        typeName: "datasetContactName"
                      }
                    }
                  ],
                  typeClass: "compound",
                  multiple: true,
                  typeName: "datasetContact"
                },
                {
                  value: [
                    {
                      dsDescriptionValue: {
                        value: description,
                        multiple: false,
                        typeClass: "primitive",
                        typeName: "dsDescriptionValue"
                      }
                    }
                  ],
                  typeClass: "compound",
                  multiple: true,
                  typeName: "dsDescription"
                },
                {
                  value: subjects,
                  typeClass: "controlledVocabulary",
                  multiple: true,
                  typeName: "subject"
                }
              ],
              displayName: "Citation Metadata"
            }
          }
        }
      }.to_json
    end
  end
end