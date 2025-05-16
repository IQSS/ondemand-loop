class UploadCollectionsController < ApplicationController
  include LoggingCommon
  include DateTimeCommon

  def create
    project_id = params[:project_id]
    project = Project.find(project_id)
    if project.nil?
      redirect_back fallback_location: root_path, alert: "Invalid project id: #{project_id}"
      return
    end

    temp_param = params[:dataset_url]
    dataset_url, repo_key = temp_param.to_s.strip.split(/\s+/, 2)
    repo_url = Repo::RepoUrlParser.parse(dataset_url)
    if repo_url.nil? || repo_url.domain.blank? || repo_url.doi.blank?
      redirect_back fallback_location: root_path, alert: "Invalid dataset URL: #{dataset_url}"
      return
    end

    file_utils = Common::FileUtils.new
    upload_collection = UploadCollection.new.tap do |c|
      c.id = file_utils.normalize_name(File.join(repo_url.domain, UploadCollection.generate_code))
      c.project_id = project_id
      c.creation_date = now
      c.type = ConnectorType::DATAVERSE
      c.name = repo_url.domain
      c.metadata = {
        dataverse_url: repo_url.repo_url,
        persistent_id: repo_url.doi,
        api_key: repo_key
      }
    end
    upload_collection.save
    log_info('Upload collection created', {upload_collection: upload_collection})
    redirect_back fallback_location: root_path, notice: "Upload Collection created: #{upload_collection.name}"
  end
end
