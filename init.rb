require 'reqs_hook_listener'

require 'wiki_controller_patch'
require 'auto_completes_controller_patch'
require 'projects_helper_patch'
require 'application_helper_patch'
require 'notifiable_patch'

Rails.configuration.to_prepare do
  unless ApplicationHelper.included_modules.include?(RequirementsApplicationHelperPatch)
    ApplicationHelper.send(:include, RequirementsApplicationHelperPatch)
  end
  unless ProjectsHelper.included_modules.include? RequirementsProjectsHelperPatch
    ProjectsHelper.send(:include, RequirementsProjectsHelperPatch)
  end
  unless WikiController.included_modules.include?(WikiControllerPatch)
    WikiController.send(:include, WikiControllerPatch)
  end
  unless AutoCompletesController.included_modules.include?(RequirementsAutocompleteControllerPatch)
    AutoCompletesController.send(:include, RequirementsAutocompleteControllerPatch)
  end
  unless Redmine::Notifiable.included_modules.include? RequirementsNotifiablePatch
    Redmine::Notifiable.send(:include, RequirementsNotifiablePatch)
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
   permission :requirements_settings, {:requirements_settings => [:show, :update]}
  end
  menu :project_menu, :requirements, { :controller => 'requirements', :action => 'index' }, :caption => :label_req, :after => :activity, :param => :project_id
  #settings :default => {'empty' => true}, :partial => 'settings/requirements_settings'

  activity_provider :requirements, :class_name => 'Requirement', :default => false
end
