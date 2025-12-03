module Dataverse
  module InstallationsParser
    private

    def parse_installations(payload, source:)
      json = JSON.parse(payload)
      installations = json.map do |entry|
        {
          id: entry['dvHubId'],
          name: entry['name'],
          hostname: entry['hostname'],
          active: entry.fetch('isActive', true),
        }
      end.compact

      active, inactive = installations.partition { |item| item[:active] }
      log_info('Completed loading Dataverse installations', {source: source, active: active.size, inactive: inactive.size})
      active
    end
  end
end
