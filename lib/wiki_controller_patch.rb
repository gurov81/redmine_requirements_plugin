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

            before_filter :try_update, :only => [:update]
            #after_filter :create
            #after_filter :update
            #after_filter :destroy
        end
    end

    module InstanceMethods

      def try_update
        #flash.now[:error] = "Could not save client"
        #render :action => 'edit'
        #render :alert => "Some errors occured"

        #redirect_to request.url, :flash => { :error => "Insufficient rights!" }
        #return
      end

      def update_with_abc(*args)
        #render :alert => "Some errors occured"
        #redirect_to request.url, :flash => { :error => "Insufficient rights!" }
        #return

        version_before = params[:content][:version]
        update_without_abc(*args)
        version_after = page_version
        Rails.logger.info "=== UpdateWikiRequirements: #{params[:project_id]} #{version_before} => #{version_after}"
        Rails.logger.info "=== UpdateWikiRequirements: args=#{args.inspect}"
        init_all unless version_before.to_i == version_after
      end

    private
      def init_all
        @notices = []
        #flash[:notice] = "Successfully saved!"
        #redirect_to request.url, :flash => { :error => "Insufficient rights!" }
        #flash[:error] = "error in save! :("
        #return

        Rails.logger.info "=== init_all :)"
        c = current_version
        p = previous_version

        cr = reqlist(params[:project_id],c)
        pr = reqlist(params[:project_id],p)

        list_add = []
        list_del = []
        #list_add = cr - pr
        #list_del = pr - cr

        cr.each do |citem|
          list_add << citem unless pr.include?(citem)
        end
        pr.each do |pitem|
          list_del << pitem unless cr.include?(pitem)
        end

        cr.each do |citem|
          pr.each do |pitem|
            code_changed = (citem.text == pitem.text and citem.req_id != pitem.req_id)
            text_changed = (citem.req_id == pitem.req_id and citem.text != pitem.text)
            if code_changed or text_changed
              list_add.delete_if { |i| i.req_id == citem.req_id }
              list_del.delete_if { |i| i.req_id == pitem.req_id }

              Rails.logger.info "=== changed requirement code/text: #{citem.project_id} #{pitem.req_id}=>#{citem.req_id} '#{pitem.text}'=>'#{citem.text}'"
              req = Requirement.find(:first,:conditions=>['req_id = ?',pitem.req_id])
              citem.url.sub! pitem.req_id, citem.req_id
              Requirement.update( req.id, :req_id => citem.req_id, :text => citem.text, :url => citem.url )
              @notices << "Changed #{citem.project_id} #{pitem.req_id}=>#{citem.req_id} '#{pitem.text}'=>'#{citem.text}'"
            end
          end
        end

        list_add.each do |r|
          begin
           Rails.logger.info "=== added requirement: #{r.project_id} #{r.req_id} #{r.text}"
           r.save!
           @notices << "Added #{r.project_id} #{r.req_id} #{r.text}"
          rescue => err
           Rails.logger.error "=== ERROR IN SAVE: #{err.to_s}"
           @notices << "Error add #{r.project_id} #{r.req_id} #{r.text} (#{err.to_s})"
          # flash.now[:error] = "error in save! :("
          # return
          end
        end
        list_del.each do |r|
          Rails.logger.info "=== removed requirement: #{r.project_id} #{r.req_id} #{r.text}"
          r.destroy
          @notices << "Removed #{r.project_id} #{r.req_id} #{r.text}"
        end

        unless @notices.empty?
          n = @notices.join('<br/>')
          flash[:notice] = n
          Rails.logger.info "===!!!!! #{n}"
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
          req = Requirement.find_or_create(project_id,r,t, "#{request.url}\##{r}")
          req.text.strip!
          rl << req
        }
      end
      rl
    end

  end
end
