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

            #before_filter :try_update, :only => [:update]
            #after_filter :create
            #after_filter :update
            #after_filter :destroy
        end
    end

    module InstanceMethods

      #def try_update
        #unless modify_requirements
          #redirect_to request.url
          #redirect_to request.url, :flash => { :error => "Insufficient rights!" }
          #return
        #end
        #flash.now[:error] = "Could not save client"
        #render :action => 'edit'
        #render :alert => "Some errors occured"
      #end

      def update_with_abc(*args)
        #render :alert => "Some errors occured"
        #redirect_to request.url, :flash => { :error => "Insufficient rights!" }
        #return

        #version_before = params[:content][:version]
        if modify_requirements?
          update_without_abc(*args)
        else
          #redirect_to request.url
          #render :action => 'edit', :params => @params, :content => params[:content]
          #render :nothing => true
          redirect_to :back
          return
        end

        #version_after = page_version
        #Rails.logger.info "=== UpdateWikiRequirements: #{params[:project_id]} #{version_before} => #{version_after}"
        #Rails.logger.info "=== UpdateWikiRequirements: args=#{args.inspect}"
        #modify_requirements unless version_before.to_i == version_after
      end

    private
      def modify_requirements?
        @notices = []
        @alerts = []
        #flash[:notice] = "Successfully saved!"
        #redirect_to request.url, :flash => { :error => "Insufficient rights!" }
        #flash[:error] = "error in save! :("
        #return

        Rails.logger.info "=== init_all :)"

        cr = extract_requirements( params[:project_id], current_version )
        pr = extract_requirements( params[:project_id], previous_version )

        duplicates(cr).each do |r|
          @alerts << "#{r}"
        end
        unless @alerts.empty?
          flash[:error] = @alerts.join('<br/>')
          return false
        end


        Rails.logger.info "=== modify_req: prev='#{previous_version}'"
        Rails.logger.info "=== modify_req: cur='#{current_version}'"

        list_add, list_del, list_mov, list_mod = diff_requirements(pr,cr)
        #alerts = check_requirements( list_add, list_del, list_mov, list_mod )
        #unless @alerts.empty?
        #  flash[:error] = @alerts.join('<br/>')
        #  return false
        #end

        Requirement.transaction do
          mmm = {}
          list_mov.each do |r|
            mmm[ r.id ] = { :req_id => r.req_id, :text => r.text, :url => r.url }
          end
          begin
            Rails.logger.info "=== try update: #{mmm.inspect}"
            Requirement.update( mmm.keys, mmm.values )
          rescue => ex
            Rails.logger.info "=== update failed: #{ex.to_s}"
          end
          list_mov.each do |r|
            Rails.logger.info "=== moved requirement code/text: #{r.project_id} #{r.req_id} '#{r.text}'"
            #Requirement.update( r.id, :req_id => r.req_id, :text => r.text, :url => r.url )
            @notices << "#{l(:notify_req_moved)} #{r.req_id} '#{r.text}'"
          end

          list_mod.each do |r|
            Rails.logger.info "=== changed requirement code/text: #{r.project_id} #{r.req_id} '#{r.text}'"
            Requirement.update( r.id, :req_id => r.req_id, :text => r.text, :url => r.url )
            @notices << "#{l(:notify_req_changed)} #{r.req_id} '#{r.text}'"
          end
          list_add.each do |r|
            begin
             Rails.logger.info "=== added requirement: #{r.project_id} #{r.req_id} #{r.text}"
             r.save!
             @notices << "#{l(:notify_req_added)} #{r.req_id} #{r.text}"
            rescue => err
             #Rails.logger.error "=== ERROR IN SAVE: #{err.to_s}"
             @alerts << "#{l(:error_req_add)} #{r.req_id} #{r.text}: (#{err.to_s})"
            end
          end
          list_del.each do |r|
            Rails.logger.info "=== removed requirement: #{r.project_id} #{r.req_id} #{r.text}"
            req = Requirement.find(:first,:conditions=>['project_id = ? and req_id = ?',r.project_id,r.req_id])
            req.destroy
            @notices << "#{l(:notify_req_deleted)} #{r.req_id} #{r.text}"
          end
        end #transaction

        unless @notices.empty?
          flash[:notice] = @notices.join('<br/>')
        end
        unless @alerts.empty?
          flash[:error] = @alerts.join('<br/>')
          return false
        end
        return true
      end

    def page_version
        @project = Project.find(params[:project_id])
        @wiki = @project.wiki
        @p = @wiki.find_page(params[:id])
        return @p.content.version
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
        @p = @wiki.find_page(params[:id])
        if @p.nil?
          return ''
        end
        vc = @p.content.versions_count
        Rails.logger.info "versions=#{vc}"

        content_to = @p.content.versions.find_by_version(@p.content.version).text
        return content_to

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

    def extract_requirements(project_id,text)
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

    def duplicates(cr)
      Rails.logger.info "!!!! dups_inspect: #{cr.inspect}"
      dups = []
      cr.each do |i|
        if cr.count { |j| i.req_id == j.req_id } > 1
          dups << "#{l(:error_req_code_exist)} '#{i.req_id}'"
        end
        if cr.count { |j| i.text == j.text } > 1
          dups << "#{l(:error_req_text_exist)} '#{i.text}'"
        end
      end
      Rails.logger.info "!!!! dups_inspect_result: #{dups.inspect}"
      return dups.uniq
    end

    def diff_requirements(pr,cr)
      list_add = []
      list_del = []
      list_mov = []
      list_mod = []

      #rename
      begin
        rescan = false
        cr.each do |citem|
          t = pr.select { |pitem| citem.text == pitem.text and citem.req_id != pitem.req_id }
          t.each do |pitem|
            cr.delete(citem)
            pr.delete(pitem)
            req = Requirement.find(:first,:conditions=>['req_id = ?',pitem.req_id])
            citem.url.sub! pitem.req_id, citem.req_id
            citem.id = req.id
            list_mov << citem
            rescan = true
            break
          end
          break if rescan
        end
      end while rescan

      #change text
      cr.each do |citem|
        t = pr.select { |pitem| citem.text != pitem.text and citem.req_id == pitem.req_id }
        t.each do |pitem|
          cr.delete(citem)
          pr.delete(pitem)
          req = Requirement.find(:first,:conditions=>['req_id = ?',pitem.req_id])
          citem.url.sub! pitem.req_id, citem.req_id
          citem.id = req.id
          list_mod << citem
        end
      end

      cr.each do |citem|
        list_add << citem unless pr.include?(citem)
      end
      pr.each do |pitem|
        list_del << pitem unless cr.include?(pitem)
      end

      return list_add, list_del, list_mov, list_mod
    end

    def check_requirements(list_add,list_del,list_mov,list_mod)
      @alerts = []
      list_add.each do |r|
        r0 = Requirement.find(:first,:conditions=>['req_id = ?',r.req_id])
        unless r0.nil?
          Rails.logger.info "!!!!! #{r0.inspect}"
          @alerts << "Add #{r.project_id} #{r.req_id} #{r.text}: already exists (#{r0.url},#{r0.inspect})"
        end
      end
      list_del.each do |r|
        @alerts << "Remove #{r.project_id} #{r.req_id} #{r.text}: dont exist" if Requirement.find(:first,:conditions=>['req_id = ?',r.req_id]).nil?
      end
      list_mov.each do |r|
        @alerts << "Move #{r.project_id} #{r.req_id} #{r.text}: dont exist" if Requirement.find(:first,:conditions=>['id = ?',r.id]).nil?
      end
      list_mod.each do |r|
        @alerts << "Modify #{r.project_id} #{r.req_id} #{r.text}: dont exist" if Requirement.find(:first,:conditions=>['id = ?',r.id]).nil?
      end
      @alerts
    end

  end
end
