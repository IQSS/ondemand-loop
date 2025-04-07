class DoiSearchController < ApplicationController
  include LoggingCommon

  def index
  end

  def search
    doi = params[:doi]

    if doi.blank?
      flash[:error] = 'Provide a valid DOI'
      redirect_to doi_search_path
      return
    end

    doi_url =URI.parse("https://doi.org/#{doi}")
    object_url = resolve(doi_url)

    if object_url.blank?
      flash[:error] = "Invalid DOI: #{doi}"
      redirect_to doi_search_path
      return
    end

    doi_resolver = Doi::DoiResolver.new(DoiResolversRegistry.resolvers)
    doi_info = doi_resolver.resolve(doi, object_url)

    if doi_info[:type] === 'dataverse'
      hostname = URI.parse(doi_info[:object_url]).hostname
      redirect_to view_dataverse_dataset_path(dv_hostname: hostname, persistent_id: doi)
    else
      flash[:error] = "DOI not supported: #{doi} type: #{doi_info[:type]}"
      redirect_to doi_search_path
    end
  end

  private
  def resolve(doi_url)
    http_client = Common::HttpClient.new
    response = http_client.head(doi_url.to_s)
    if response.redirect?
      object_url = response.location
      log_info('DOI resolved', {doi_url: doi_url, object_url: object_url})
      object_url
    else
      log_info('Unable to resolve DOI', {doi_url: doi_url, response: response.status})
      nil
    end

  end

end
