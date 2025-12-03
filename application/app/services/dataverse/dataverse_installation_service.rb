module Dataverse
  class DataverseInstallationService
    SUPPORTED_SCHEMES = %w[http https file].freeze

    def initialize(url:, http_client: Common::HttpClient.new, expires_in: Dataverse::DataverseHub::DEFAULT_CACHE_EXPIRY)
      @url = url
      @http_client = http_client
      @expires_in = expires_in
    end

    def installations
      provider.installations
    end

    private

    def provider
      @provider ||= begin
        uri = URI.parse(@url)
        scheme = uri.scheme&.downcase
        raise ArgumentError, "Unsupported Dataverse installations URI: #{@url}" if scheme.present? && !SUPPORTED_SCHEMES.include?(scheme)

        if scheme == 'file'
          Dataverse::DataverseInstallationFile.new(path: uri.path, expires_in: @expires_in)
        else
          Dataverse::DataverseHub.new(url: @url, http_client: @http_client, expires_in: @expires_in)
        end
      end
    end
  end
end
