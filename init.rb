require 'reqs_hook_listener'

require 'wiki_formatter_patch'
require 'wiki_controller_patch'

Rails.configuration.to_prepare do
  unless Redmine::WikiFormatting::Textile::Formatter.included_modules.include? WikiFormatterPatch
    Redmine::WikiFormatting::Textile::Formatter.send(:include, WikiFormatterPatch)
  end
  unless WikiController.included_modules.include?(WikiControllerPatch)
    WikiController.send(:include, WikiControllerPatch)
  end
end

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
   #permission :requirements_settings, {:requirements_settings => [:show, :update]}
  end
  menu :project_menu, :requirements, { :controller => 'requirements', :action => 'index' }, :caption => :label_req, :after => :activity, :param => :project_id
  #settings :default => {'empty' => true}, :partial => 'settings/requirements_settings'
end

