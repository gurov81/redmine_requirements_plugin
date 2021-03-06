# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'requirements', :to => 'requirements#index'

match '/requirements/show/:id', :to => 'requirements#show', :via => :get, :constraints => { :id => /[\w+\.%-]+/ }

match '/requirements/auto_complete', :to => 'auto_completes#requirements', :via => :get, :as => 'auto_complete_requirements'
match '/requirement_links/add_link', :controller => :requirement_links, :action => 'add_link', :via => [:post]
match '/requirement_links/del_link', :controller => :requirement_links, :action => 'del_link', :via => [:post, :delete, :get]

match '/requirements/trace', :controller => :requirements, :action => 'trace', :via => [:get]
match 'projects/:id/requirements_settings/:action', :controller => 'requirements_settings', :via => [:get, :post, :put]
