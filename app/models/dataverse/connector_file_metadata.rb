# frozen_string_literal: true

module Dataverse
  class ConnectorFileMetadata
    def initialize(metadata = {})
      @metadata = metadata.to_h.deep_symbolize_keys
    end

    def to_hash
      @metadata.deep_stringify_keys
    end
  end
end
