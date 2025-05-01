module Dataverse
  class HubRegistry
    include LoggingCommon
    CACHE_KEY = 'dataverse_hub_installations'
    CACHE_EXPIRY = 24.hours.freeze
    HUB_API_URL = 'https://hub.dataverse.org/api/installation'

    def initialize(http_client: Common::HttpClient.new(base_url: HUB_API_URL), cache: Rails.cache)
      @http_client = http_client
      @cache = cache
    end

    def installations
      @cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
        log_info('Fetching Dataverse Hub installations...', {url: HUB_API_URL})
        fetch_installations
      end
    end

    private

    def fetch_installations
      response = @http_client.get(HUB_API_URL)
      if response.success?
        json = JSON.parse(response.body)
        installations = json.map do |entry|
          {
            id: entry['dvHubId'],
            name: entry['name'],
            hostname: entry['hostname'],
          }
        end.compact

        log_info('Completed loading Dataverse installations', {servers: installations.size})
        installations
      else
        log_error('Failed to fetch Dataverse Hub data', {url: HUB_API_URL, response: response.status})
        []
      end
    rescue => e
      log_error('Error fetching Dataverse Hub data', {url: HUB_API_URL}, e)
      []
    end
  end
end
