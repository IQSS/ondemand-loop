module Zenodo::Handlers
  class DatasetFormTabs
    include LoggingCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      []
    end

    def edit(upload_bundle, request_params)
      depositions = depositions(upload_bundle)
      log_info('Dataset form tabs', { upload_bundle: upload_bundle.id, depositions: depositions.total_count })

      ConnectorResult.new(
        template: '/connectors/zenodo/dataset_form_tabs',
        locals: { upload_bundle: upload_bundle, depositions: depositions }
      )
    end

    def update(upload_bundle, request_params)
      raise NotImplementedError, 'Only edit is supported for DatasetFormTabs'
    end

    private

    def depositions(upload_bundle)
      connector_metadata = upload_bundle.connector_metadata
      api_key = connector_metadata.api_key.value
      service = Zenodo::UserService.new(zenodo_url: connector_metadata.zenodo_url, api_key: api_key)
      service.list_depositions
    end
  end
end
