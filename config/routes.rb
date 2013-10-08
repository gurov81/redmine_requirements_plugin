# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'requirements', :to => 'requirements#index'

match '/requirements/auto_complete', :to => 'auto_completes#requirements', :via => :get, :as => 'auto_complete_requirements'
match '/requirements/add_link', :controller => :requirements, :action => 'add_link', :via => [:post]
match '/requirements/del_link', :controller => :requirements, :action => 'del_link', :via => [:post, :delete, :get]

match '/requirements/trace', :controller => :requirements, :action => 'trace', :via => [:get]
match 'projects/:id/requirements_settings/:action', :controller => 'requirements_settings', :via => [:get, :post, :put]
