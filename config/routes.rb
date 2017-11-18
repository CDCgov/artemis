Rails.application.routes.draw do
  resources :reports, only: %i[index show new create] do
    collection do
      get :latest
    end
  end
  post :fhir, to: 'main#fhir'
  root 'main#index'
end
