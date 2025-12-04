module Dataverse
  class DataverseInstallationFile
    include LoggingCommon
    include Dataverse::InstallationsParser

    def initialize(path:, expires_in: Dataverse::DataverseHub::DEFAULT_CACHE_EXPIRY)
      @path = path
      @expires_in = expires_in
      @installations = []
      @last_loaded_at = nil
    end

    def installations
      if cache_expired?
        log_info('Loading Dataverse installations from file', { path: @path })
        result = load_installations
        if result.present?
          @installations = result
          @last_loaded_at = Time.current
        end
      end

      @installations
    end

    private

    def cache_expired?
      @last_loaded_at.nil? || Time.current - @last_loaded_at > @expires_in
    end

    def load_installations
      raise ArgumentError, 'Missing dataverse installations file path' if @path.blank?

      payload = File.read(@path)
      parse_installations(payload, source: @path)
    rescue => e
      log_error('Failed to read Dataverse Hub file data', { path: @path }, e)
      []
    end
  end
end
