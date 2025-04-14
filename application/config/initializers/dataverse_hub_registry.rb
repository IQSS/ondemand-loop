# DataverseHubRegistry
#
module DataverseHubRegistry
  mattr_accessor :registry

  def self.build_initializers
    Dataverse::HubRegistry.new
  end

end

Rails.application.config.to_prepare do
  DataverseHubRegistry.registry = DataverseHubRegistry.build_initializers

  Rails.logger.info "[DataverseHubRegistry] Loaded"
end