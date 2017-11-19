Rails.application.routes.draw do
  resources :reports, only: %i[index show new create] do
    post :fhir
    collection do
      get :latest
    end
  end
  root 'main#index'
end
