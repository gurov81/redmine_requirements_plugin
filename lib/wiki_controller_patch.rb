require_dependency 'wiki_controller'

module WikiControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            #after_filter :ddd, :only => [:create, :update, :destroy]
            #alias_method_chain :edit, :abc
            #alias_method_chain :show, :abc
            alias_method_chain :update, :abc
            #alias_method_chain :destroy, :abc

            #before_filter :init_all, :only => [:update, :destroy]
            #after_filter :create
            #after_filter :update
            #after_filter :destroy
        end
    end

    module InstanceMethods

      def update_with_abc(*args)
        version_before = params[:content][:version]
        update_without_abc(*args)
        version_after = page_version
        Rails.logger.info "=== UpdateWikiRequirements: #{params[:project_id]} #{version_before} => #{version_after}"
        init_all unless version_before.to_i == version_after
      end

    private
      def init_all
        c = current_version
        p = previous_version

        cr = reqlist(params[:project_id],c)
        pr = reqlist(params[:project_id],p)

        cr.each do |r|
          if !pr.include?(r)
            Rails.logger.info "=== added requirement: #{r.project_id} #{r.req_id} #{r.text}"
            r.save!
          end
        end
        pr.each do |r|
          if !cr.include?(r)
            Rails.logger.info "=== removed requirement: #{r.project_id} #{r.req_id} #{r.text}"
            r.destroy
          end
        end
      end

    def page_version
        @project = Project.find(params[:project_id])
        @wiki = @project.wiki
        @page = @wiki.find_page(params[:id])
        return @page.content.version
    end

    def current_version
        project_id = params[:project_id]
        content = params[:content]
        #if content.nil?
        #  @project = Project.find(params[:project_id])
        #  @wiki = @project.wiki
        #  @page = @wiki.find_page(params[:id])
        #  content = @page.content
        #end
        text = content[:text]
        text
    end

    def previous_version
        project_id = params[:project_id]
        content = params[:content]
        #if content.nil?
        #  return ""
        #end
        cver = content[:version].to_i
        pver = content[:version].to_i-1
        @project = Project.find(params[:project_id])
        @wiki = @project.wiki
        @page = @wiki.find_page(params[:id])
        vc = @page.content.versions_count
        Rails.logger.info "versions=#{vc}"

        content_to = @page.content.versions.find_by_version(@page.content.version).text
        from = @page.content.versions.find_by_version(@page.content.version.to_i-1)
        content_from = ""
        if not from.nil?
          content_from = from.text
        end

        #Rails.logger.info "!!! to='#{content_to}' from='#{content_from}'"
        
        text = content_from #content.find_version(1) #versions.before(cver) # @page.content_for_version("1")
        #t = @page.content_for_version(v) #[:text]
        #Rails.logger.info "??? prevVersion: ver=#{pver}/#{cver} t='#{text}'"
        text
    end

    def reqlist(project_id,text)
      rl = []
      unless text.nil?
        text.scan(Regexp.new("^(REQ[-]?[0-9.]+)(\\s+.+?)$")) { |r, t|
          #Rails.logger.info "reqlist:: req='#{r}' pr='#{project_id}' text='#{t}'"
          req = Requirement.find_or_create(project_id,r,t)
          rl << req
        }
      end
      rl
    end

  end
end
