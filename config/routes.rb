Rails.application.routes.draw do
  post   '/sign_in',        to: 'sessions#sign_in'
  delete '/sign_out',       to: 'sessions#sign_out'
  patch  '/confirm',        to: 'sessions#confirm'
  post   '/reset_password', to: 'sessions#request_reset_password'
  patch  '/reset_password', to: 'sessions#reset_password'

  get    '/users',          to: 'users#index'
  post   '/users',          to: 'users#create'
  patch  '/users/:id',      to: 'users#update'
  get    '/users/:id',      to: 'users#show'

  get    '/clients',        to: 'clients#index'
  post   '/clients',        to: 'clients#create'
  patch  '/clients/:id',    to: 'clients#update'
  get    '/clients/:id',    to: 'clients#show'
end
