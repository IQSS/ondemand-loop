# frozen_string_literal: true

module Zenodo
  class DownloadConnectorMetadata
    delegate_missing_to :metadata

    def initialize(download_file)
      @metadata = ActiveSupport::OrderedOptions.new
      @metadata.merge!(download_file.metadata.to_h.deep_symbolize_keys)
      @project_id = download_file.project_id
      @download_file = download_file
    end

    def repo_name
      "Zenodo"
    end

    def explore_url
      repo_url = Repo::RepoUrl.parse(zenodo_url)
      Rails.application.routes.url_helpers.explore_path(
        connector_type: ConnectorType::ZENODO.to_s,
        server_domain: repo_url.domain,
        object_type: type,
        object_id: type_id,
        server_scheme: repo_url.scheme_override,
        server_port: repo_url.port_override,
        active_project: @project_id
      )
    end

    def external_url
      return nil unless zenodo_url && type_id

      case type
      when 'records'
        Zenodo::Concerns::ZenodoUrlBuilder.build_record_url(zenodo_url, type_id)
      when 'depositions'
        Zenodo::Concerns::ZenodoUrlBuilder.build_deposition_url(zenodo_url, type_id)
      else
        zenodo_url
      end
    end

    def repo_summary
      return nil unless external_url

      OpenStruct.new(
        type: @download_file.type,
        date: @download_file.creation_date,
        title: title,
        url: external_url,
        note: type
      )
    end

    def to_h
      metadata.to_h.deep_stringify_keys
    end

    private

    attr_reader :metadata
  end
end
