Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "downloads" => "downloads#index", as: :downloads
  get "downloads/collections" => "downloads#collections", as: :downloads_collections

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
  root "downloads#index"
end
