module ExploreHelper

  def link_to_explore(connector, repo_url, type:, id:, **params)
    raise ArgumentError, "Invalid connector: #{connector}" unless connector.is_a?(ConnectorType)
    explore_path({
                   connector_type: connector.to_s,
                   server_domain: repo_url.domain,
                   server_scheme: repo_url.scheme_override,
                   server_port: repo_url.port_override,
                   object_type: type,
                   object_id: id
                 }.merge(params))
  end

  def link_to_landing(connector, **params)
    raise ArgumentError, "Invalid connector: #{connector}" unless connector.is_a?(ConnectorType)
    connect_repo_path({ connector_type: connector.to_s, object_type: 'landing' }.merge(params))
  end
end
