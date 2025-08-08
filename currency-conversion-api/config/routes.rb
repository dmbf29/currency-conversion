Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :conversions, only: [ :index ]
      post "/convert", to: "conversions#create"
    end
  end
end
