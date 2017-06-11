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

  post   '/documents',      to: 'documents#create'
  patch  '/documents/:id',  to: 'documents#update'
  delete '/documents/:id',  to: 'documents#destroy'
  get    '/documents/:id',  to: 'documents#show'

  get    '/places',         to: 'places#index'
  post   '/places',         to: 'places#create'
  patch  '/places/:id',     to: 'places#update'
  get    '/places/:id',     to: 'places#show'

  get    '/rents',          to: 'rents#index'
  post   '/rents',          to: 'rents#create'
  patch  '/rents/:id',      to: 'rents#update'
  get    '/rents/:id',      to: 'rents#show'
  delete '/rents/:id',      to: 'rents#destroy'
end
