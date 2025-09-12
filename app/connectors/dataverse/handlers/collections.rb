module Dataverse::Handlers
  class Collections
    include LoggingCommon

    def initialize(object_id = nil)
      @collection_id = object_id
    end

    def params_schema
      [
        :repo_url,
        :page,
        :query
      ]
    end

    def show(request_params)
      dataverse_url = request_params[:repo_url].server_url
      page = request_params[:page] ? request_params[:page].to_i : 1
      search_query = request_params[:query].present? ? ActionView::Base.full_sanitizer.sanitize(request_params[:query]) : nil
      service = Dataverse::CollectionService.new(dataverse_url)
      begin
        collection = service.find_collection_by_id(@collection_id)
        search_result = service.search_collection_items(@collection_id, page: page, query: search_query)
        if collection.nil? || search_result.nil?
          log_error('Dataverse collection not found.', { dataverse: dataverse_url, collection_id: @collection_id })
          return ConnectorResult.new(
            message: { alert: I18n.t('connectors.dataverse.collections.show.dataverse_not_found', dataverse_url: dataverse_url, id: @collection_id) },
            success: false
          )
        end
        collection_url = Dataverse::Concerns::DataverseUrlBuilder.build_collection_url(dataverse_url, @collection_id)
        ::Configuration.repo_history.add_repo(
          collection_url,
          ConnectorType::DATAVERSE,
          title: collection.data.name,
          note: 'collection'
        )

        log_info('Collections.show completed', { dataverse: dataverse_url, collection_id: @collection_id })
        ConnectorResult.new(
          template: '/connectors/dataverse/collections/show',
          locals: {
            collection: collection,
            search_result: search_result,
            dataverse_url: dataverse_url,
            repo_url: request_params[:repo_url]
          },
          resource: collection,
          success: true
        )
      rescue Dataverse::CollectionService::UnauthorizedException => e
        log_error('Dataverse requires authorization', { dataverse: dataverse_url, collection_id: @collection_id }, e)
        ConnectorResult.new(
          message: { alert: I18n.t('connectors.dataverse.collections.show.dataverse_requires_authorization', dataverse_url: dataverse_url, id: @collection_id) },
          success: false
        )
      rescue => e
        log_error('Dataverse service error', { dataverse: dataverse_url, collection_id: @collection_id }, e)
        ConnectorResult.new(
          message: { alert: I18n.t('connectors.dataverse.collections.show.dataverse_service_error', dataverse_url: dataverse_url, id: @collection_id) },
          success: false
        )
      end
    end
  end
end

