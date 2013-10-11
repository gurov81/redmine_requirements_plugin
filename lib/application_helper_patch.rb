require_dependency 'application_helper'

module RequirementsApplicationHelperPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :textilizable, :requirement
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def textilizable_with_requirement(*args)
            options = args.last.is_a?(Hash) ? args.pop : {}
            case args.size
            when 1
                obj = options[:object]
            when 2
                obj = args[0]
            end

            project = options[:project] || @project || (obj && obj.respond_to?(:project) ? obj.project : nil)

            text = textilizable_without_requirement(*args)

            prefix_list = RequirementSetting.prefixes(project.id)
            return text if prefix_list.nil?

            Rails.logger.info "hehehe :) preflist=#{prefix_list.inspect}"
            #Rails.logger.info "======= before text='#{text.inspect}'\n"

            baseurl = "" #Redmine::Utils.relative_url_root
            src = baseurl + "/requirements/show/"

            text.gsub!(Regexp.new("<br />"), "<br/>")
            text.gsub!(Regexp.new("\\b((#{prefix_list})[-]?)([0-9.]+)(\\s+.+?)(<br/>|</p>|</h\\d+>)"),
              "<a name=\"\\1\\3\"/><a href=\""+src+"\\1\\3?project_id=#{project.id}\" >\\3\\4</a><a href=\"#\\1\\3\" class=\"wiki-anchor\">&para;</a>\\5" )
            #Rails.logger.info "======= after text='#{text.inspect}'"

            text.html_safe
        end


    end

end
