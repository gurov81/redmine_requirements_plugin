require_dependency 'auto_completes_controller'

module RequirementsAutocompleteControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
        end
    end

    module InstanceMethods

      def requirements
        #Rails.logger.info "!!!!!! autocomplete: params=#{params.inspect}"
        @reqs = [] #Requirement.all

        #q = (params[:q] || params[:term]).to_s.strip
        #Rails.logger.info "!!!!!! AAA #{q.inspect}"
        #@reqs = Requirement.where("req_id like ? or text like ?", "%#{q}%", "%#{q}%").limit(10)
        #Rails.logger.info "!!!!!! BBB #{@reqs.inspect}"
        #render :layout => false
        #return

        q = (params[:q] || params[:term]).to_s.strip
        if q.present?
          scope = (params[:scope] == "all" || @project.nil? ? Requirement : Requirement) #.visible
          if q.match(/\A#?(\d+)\z/)
            @reqs << scope.find_by_id($1.to_i)
          end
          @reqs += scope.where("LOWER(req_id) like LOWER(?) or LOWER(text) like LOWER(?)", "%#{q}%", "%#{q}%").order("req_id ASC").limit(10)
          #@reqs += scope.where("LOWER(#{Requirement.table_name}.req_id) LIKE LOWER(?)", "%#{q}%").order("#{Requirement.table_name}.id DESC").limit(10).all
          @reqs.compact!
        end
        #Rails.logger.info "!!!!!! autocomplete: params=#{params.inspect} requirements=#{@reqs.inspect}"
        render :layout => false
      end

    end
end

