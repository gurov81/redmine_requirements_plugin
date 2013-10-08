require_dependency 'projects_helper'

module RequirementsProjectsHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, RequirementsProjectsTabs)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :project_settings_tabs, :requirements
    end

  end
end

module RequirementsProjectsTabs
  def project_settings_tabs_with_requirements
    tabs = project_settings_tabs_without_requirements
    action = {:name => :requirements,
      :controller => 'requirements_settings',
      :action => :show,
      :partial => 'requirements_settings/show',
      :label => :label_req}

    tabs << action if User.current.allowed_to?(action, @project)

    tabs
  end
end

