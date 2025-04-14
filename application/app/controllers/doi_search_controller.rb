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

    #TODO: Inject DOI Api url from configuration
    object_url = Doi::DoiService.new.resolve(doi)
    if object_url.blank?
      flash[:error] = "Invalid DOI: #{doi}"
      redirect_to doi_search_path
      return
    end

    doi_resolver = Doi::DoiResolverService.new(DoiResolversRegistry.resolvers)
    doi_info = doi_resolver.resolve(doi, object_url)

    #TODO: This needs to be handled by a connector specific class
    if doi_info[:type] === 'dataverse'
      hostname = URI.parse(doi_info[:object_url]).hostname
      redirect_to view_dataverse_dataset_path(dv_hostname: hostname, persistent_id: doi)
    else
      flash[:error] = "DOI not supported: #{doi} type: #{doi_info[:type]}"
      redirect_to doi_search_path
    end
  end

end
