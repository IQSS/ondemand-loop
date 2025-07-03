module Dataverse
  class CitationMetadataResponse
    attr_reader :status, :subjects

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @subjects = get_subjects(parsed)
    end

    private

    def get_subjects(parsed)
      parsed.dig(:data, :fields, :subject, :controlledVocabularyValues) || []
    end
  end
end