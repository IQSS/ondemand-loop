class DoiSearchController < ApplicationController
  include LoggingCommon

  def index
  end

  def search
    doi = params[:doi]

    if doi.blank?
      redirect_to doi_search_path, alert: 'Provide a valid DOI'
      return
    end

    #TODO: Inject DOI Api url from configuration
    object_url = Doi::DoiService.new.resolve(doi)
    if object_url.blank?
      redirect_to doi_search_path, alert: "Invalid DOI: #{doi}"
      return
    end

    doi_resolver = Doi::DoiResolverService.new(DoiResolversRegistry.resolvers)
    doi_info = doi_resolver.resolve(doi, object_url)

    #TODO: This needs to be handled by a connector specific class
    if doi_info[:type] === 'dataverse'
      hostname = URI.parse(doi_info[:object_url]).hostname
      redirect_to view_dataverse_dataset_path(dv_hostname: hostname, persistent_id: doi)
    else
      redirect_to doi_search_path, alert: "DOI not supported: #{doi} type: #{doi_info[:type]}"
    end
  end

end
