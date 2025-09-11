module Zenodo::Handlers
  class Landing
    include LoggingCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      [
        :query,
        :page,
        :repo_url
      ]
    end

    def show(request_params)
      query = request_params[:query]
      page = request_params[:page]&.to_i || 1
      repo_url = request_params[:repo_url]
      log_info('Landing.show', { repo_url: repo_url.to_s, query: query, page: page })
      results = nil

      if query.present?
        service = Zenodo::SearchService.new(zenodo_url: repo_url.server_url)
        results = service.search(query, page: page)
        if results.nil?
          return ConnectorResult.new(
            message: { alert: I18n.t('zenodo.landing.message_search_error') },
            success: false
          )
        end
      end

      log_info('Landing.show completed', { repo_url: repo_url.to_s, query: query, page: page, results: results&.items&.size })
      ConnectorResult.new(
        template: '/connectors/zenodo/landing/index',
        locals: { query: query, results: results, page: page, repo_url: repo_url },
        success: true
      )
    end
  end
end

