Rails.application.routes.draw do
  resources :reports, only: %i[index show new create] do
    collection do
      get :latest
    end
  end
  root 'main#index'
end
