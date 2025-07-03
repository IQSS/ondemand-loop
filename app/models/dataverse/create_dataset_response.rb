module Dataverse
  class CreateDatasetResponse
    attr_reader :status, :id, :persistent_id, :message

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @id = parsed.dig(:data, :id)
      @persistent_id = parsed.dig(:data, :persistentId)
      @message = parsed[:message]
    end
  end
end