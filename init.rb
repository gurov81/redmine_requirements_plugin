require 'reqs_hook_listener'

Redmine::Plugin.register :redmine_wiki_requirements do
  name 'Redmine Wiki Requirements plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :requirements do
   #permission :requirements, { :requirements => [:index] }, :public => true
   permission :view_requirements, :requirements => :index
   #permission :edit_requirements, :requirements => :index
  end
  menu :project_menu, :requirements, { :controller => 'requirements', :action => 'index' }, :caption => :menu_title, :after => :activity, :param => :project_id
end
