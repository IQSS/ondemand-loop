Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "downloads" => "downloads#index", as: :downloads
  get "downloads/files" => "downloads#files", as: :downloads_files
  post "downloads/:project_id/:file_id/cancel" => "files#cancel", as: :downloads_file_cancel
  delete "downloads/:project_id/:file_id" => "files#destroy", as: :downloads_file_delete

  get "uploads" => "uploads#index", as: :uploads
  get "uploads/files" => "uploads#files", as: :uploads_files

  post "uploads/:project_id/:collection_id/:file_id/cancel" => "files#cancel_upload", as: :uploads_file_cancel
  post "uploads/:project_id/:collection_id/add" => "upload_files#add", as: :uploads_file_add
  get "uploads/:project_id/:collection_id/files" => "upload_files#files", as: :uploads_file_files
  delete "uploads/:project_id/:collection_id/:file_id" => "upload_files#delete_file", as: :uploads_file_delete
  post "uploads/:project_id/create" => "upload_files#create_collection", as: :uploads_file_create_collection

  resources :projects
  post "/projects/:id/set_active" => "projects#set_active", as: :project_set_active

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

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "projects#index"
end
