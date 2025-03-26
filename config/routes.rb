Rails.application.routes.draw do
  get "downloads" => "downloads#index", as: :downloads
  get "integrations/dataverse/external_tool/dataset" => "dataverse/external_tool#dataset"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Dataverse routes
  post "/view/dataverse/:metadata_id/datasets/:id/download" => "dataverse/datasets#download", as: :download_dataverse_dataset_files
  get "/view/dataverse/:metadata_id/datasets/:id" => "dataverse/datasets#show", as: :view_dataverse_dataset

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "downloads#index"
end
