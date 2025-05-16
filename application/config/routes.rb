Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "downloads" => "downloads#index", as: :downloads
  get "downloads/files" => "downloads#files", as: :downloads_files
  get "uploads" => "uploads#index", as: :uploads
  get "uploads/files" => "uploads#files", as: :uploads_files

  # CRUD over /projects and /projects/:id
  # post /projects/:id/set_active => set project as active
  resources :projects do
    post "set_active" => "projects#set_active", on: :member, as: :project_set_active

    # post /projects/:project_id/download_files/:id/cancel => cancel download file
    # delete /projects/:project_id/download_files/:id => delete download file
    resources :download_files, only: [:destroy] do
      post "cancel" => "download_files#cancel", on: :member, as: :downloads_file_cancel
    end

    # post /projects/:project_id/upload_collections => create new collection
    resources :upload_collections, only: [:create] do
      # post /projects/:project_id/upload_collections/:upload_collection_id/upload_files => create new upload_file
      # get /projects/:project_id/upload_collections/:upload_collection_id/upload_files => get upload_files from a collection
      # delete /projects/:project_id/upload_collections/:upload_collection_id/upload_files/:id => delete upload_file
      # post /projects/:project_id/upload_collections/:upload_collection_id/upload_files/:id/cancel => cancel upload_file
      resources :upload_files, only: [:create, :index, :destroy] do
        post "cancel" => "upload_files#cancel", on: :member, as: :uploads_file_cancel
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

  # DOI ROUTES
  get "/view/doi/search" => 'doi_search#index', as: :doi_search
  post '/view/doi/search' => 'doi_search#search', as: :doi_search_post
  get "/view/doi/search/*doi" => 'doi_search#search', as: :doi_resolve
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
