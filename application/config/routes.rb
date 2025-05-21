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

    # post /projects/:project_id/uploads => create new collection
    # get /projects/:project_id/uploads => get collections from a project
    resources :upload_collections, path: 'uploads', only: [ :create, :index, :edit, :update, :destroy ] do
      # post /projects/:project_id/uploads/:upload_collection_id/files => create new upload_file
      # get /projects/:project_id/uploads/:upload_collection_id/files => gets upload_files from a collection
      # delete /projects/:project_id/uploads/:upload_collection_id/files/:id => delete upload_file
      # post /projects/:project_id/uploads/:upload_collection_id/files/:id/cancel => cancel upload_file
      resources :upload_files, path: 'files', only: [ :create, :index, :destroy ] do
        post :cancel, on: :member
      end
    end
  end

  # FILE BROWSER
  get '/file_browser', to: 'file_browser#index'


  # DATAVERSE ROUTES
  get "integrations/dataverse/external_tool/dataset" => "dataverse/external_tool#dataset"

  post "/view/dataverse/download/dataset" => "dataverse/datasets#download", as: :download_dataverse_dataset_files
  get "/view/dataverse" => "dataverse/dataverses#index", as: :view_dataverse_landing
  get "/view/dataverse/*dv_hostname/datasets/*persistent_id" => "dataverse/datasets#show", as: :view_dataverse_dataset, format: false
  get "/view/dataverse/*dv_hostname/dataverses/:id" => "dataverse/dataverses#show", as: :view_dataverse, format: false

  # REPO RESOLVER ROUTES
  post '/view/repo/resolve' => 'repo_resolver#resolve', as: :repo_resolver

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "projects#index"
end
