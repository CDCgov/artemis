Rails.application.routes.draw do
  resources :reports, only: %i[index show create] do
    collection do
      get :latest
    end
  end
  root to: redirect(path: '/reports/latest')
end
