module Zenodo
  class RecordService
    include LoggingCommon

    def initialize(zenodo_url = Zenodo::ZenodoUrl::DEFAULT_URL, http_client: Common::HttpClient.new(base_url: zenodo_url))
      @zenodo_url = zenodo_url
      @http_client = http_client
    end

    def find_record(record_id)
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('records')
              .add_path(record_id)
              .to_s
      response = @http_client.get(url)
      return nil unless response.success?
      RecordResponse.new(response.body)
    end

    def get_or_create_deposition(record_id, api_key:, concept_id: nil)
      headers = {
        'Content-Type' => 'application/json',
        ApiService::AUTH_HEADER => "Bearer #{api_key}"
      }

      log_info('Getting/Creating deposition', { record: record_id, concept: concept_id })
      unless concept_id
        record_url = FluentUrl.new('')
                       .add_path('api')
                       .add_path('records')
                       .add_path(record_id)
                       .to_s
        record_resp = @http_client.get(record_url, headers: headers)
        return nil if record_resp.not_found?
        raise ApiService::UnauthorizedException if record_resp.unauthorized?
        raise "Error retrieving record #{record_id}: #{record_resp.status} - #{record_resp.body}" unless record_resp.success?

        record_body = JSON.parse(record_resp.body)
        concept_id = record_body['conceptrecid'].to_s
      end

      # Step 2: look for existing draft depositions
      list_url = FluentUrl.new('')
                   .add_path('api')
                   .add_path('deposit')
                   .add_path('depositions')
                   .add_param('conceptrecid', concept_id)
                   .to_s
      list_resp = @http_client.get(list_url, headers: headers)
      raise ApiService::UnauthorizedException if list_resp.unauthorized?
      raise "Error retrieving depositions: #{list_resp.status} - #{list_resp.body}" unless list_resp.success?

      depositions = JSON.parse(list_resp.body)
      draft = depositions.find { |d| d['submitted'] == false }

      if draft
        deposition_id = draft['id'].to_s
      else
        # Step 3: create a new draft using newversion action
        new_url = FluentUrl.new('')
                   .add_path('api')
                   .add_path('deposit')
                   .add_path('depositions')
                   .add_path(record_id.to_s)
                   .add_path('actions')
                   .add_path('newversion')
                   .to_s
        new_resp = @http_client.post(new_url, headers: headers)
        raise ApiService::UnauthorizedException if new_resp.unauthorized?
        raise "Error creating draft deposition: #{new_resp.status} - #{new_resp.body}" unless new_resp.success?

        body = JSON.parse(new_resp.body)
        latest_draft = body.dig('links', 'latest_draft')
        deposition_id = latest_draft&.split('/')&.last&.to_s
      end

      return nil unless deposition_id

      dep_url = FluentUrl.new('')
                  .add_path('api')
                  .add_path('deposit')
                  .add_path('depositions')
                  .add_path(deposition_id)
                  .to_s
      dep_resp = @http_client.get(dep_url, headers: headers)
      raise ApiService::UnauthorizedException if dep_resp.unauthorized?
      raise "Error retrieving deposition #{deposition_id}: #{dep_resp.status} - #{dep_resp.body}" unless dep_resp.success?

      DepositionResponse.new(dep_resp.body).tap do |deposition|
        log_info('Completed', { record: record_id, concept: concept_id, result: deposition })
      end
    end
  end
end
