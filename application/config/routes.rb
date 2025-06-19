Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Routes for Downloads and Uploads pages
  get "downloads" => "download_status#index", as: :download_status
  get "downloads/files" => "download_status#files", as: :download_status_files
  get "uploads" => "upload_status#index", as: :upload_status
  get "uploads/files" => "upload_status#files", as: :upload_status_files

  # REST routes over /projects and /projects/:id
  # post /projects/:id/set_active => set project as active
  resources :projects do
    post :set_active, on: :member

    # delete /projects/:project_id/downloads/files/:id => delete download file
    # post /projects/:project_id/downloads/files/:id/cancel => cancel download file
    resources :download_files, path: 'downloads/files', only: [ :destroy ] do
      post :cancel, on: :member
    end

    # post /projects/:project_id/uploads => create new upload batch
    # get /projects/:project_id/uploads => get batches from a project
    resources :upload_bundles, path: 'uploads', only: [:create, :index, :edit, :update, :destroy ] do
      # post /projects/:project_id/uploads/:upload_bundle_id/files => create new upload_file
      # get /projects/:project_id/uploads/:upload_bundle_id/files => gets upload_files from a collection
      # delete /projects/:project_id/uploads/:upload_bundle_id/files/:id => delete upload_file
      # post /projects/:project_id/uploads/:upload_bundle_id/files/:id/cancel => cancel upload_file
      resources :upload_files, path: 'files', only: [ :create, :index, :destroy ] do
        post :cancel, on: :member
      end
    end
  end

  #FILE ACTIVITY
  get '/detached_process/status', to: 'detached_process#status'
  # FILE BROWSER
  get '/file_browser', to: 'file_browser#index'
  #WIDGETS
  get '/widgets/*widget_path', to: 'widgets#show', via: [:get], as: 'widgets'



  # DATAVERSE ROUTES
  get "integrations/dataverse/external_tool/dataset" => "dataverse/external_tool#dataset"

  post "/view/dataverse/download/dataset" => "dataverse/datasets#download", as: :download_dataverse_dataset_files
  get "/view/dataverse" => "dataverse/landing_page#index", as: :view_dataverse_landing
  get "/view/dataverse/*dv_hostname/datasets/*persistent_id" => "dataverse/datasets#show", as: :view_dataverse_dataset, format: false
  get "/view/dataverse/*dv_hostname/dataverses/:id" => "dataverse/collections#show", as: :view_dataverse, format: false

  # ZENODO ROUTES
  post "/view/zenodo/download/record" => "zenodo/records#download", as: :download_zenodo_record_files
  get "/view/zenodo" => "zenodo/landing_page#index", as: :view_zenodo_landing
  get "/view/zenodo/records/:id" => "zenodo/records#show", as: :view_zenodo_record, format: false

  # REPO RESOLVER ROUTES
  post '/view/repo/resolve' => 'repo_resolver#resolve', as: :repo_resolver

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "projects#index"
end
