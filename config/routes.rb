Rails.application.routes.draw do
  resources :reports, only: %i[index show new create] do
    collection do
      get :latest
    end
  end
  #root to: redirect(path: '/main')
  root  'main#index'
end
