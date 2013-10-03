class ReqsHookListener < Redmine::Hook::ViewListener

  def view_projects_show_left(context={} )
    return content_tag("p", "Custom content added to the left")
  end

  def view_projects_show_right(context={} )
    return content_tag("p", "Custom content added to the right")
  end

  #def view_issues_show_details_bottom(context={ })
  def view_issues_show_description_bottom(context = {})
    issue = context[:issue]
    return '' unless issue.project.module_enabled? 'requirements'

    requirement_tracker_id = 1
    project = context[:project]
    snippet = ''
    if requirement_tracker_id == issue.tracker_id
      snippet << show_requirement_cases(issue, project)
    end
    return snippet
  end

  def view_issues_form_details_bottom(context = {})
    issue = context[:issue]
    return '' unless issue.project.module_enabled? 'requirements'

    requirement_tracker_id = 1
    project = context[:project]
    
    snippet = ''
    style = (requirement_tracker_id == issue.tracker_id) ? '' : 'style="display: none;"'
    req_tracker_ids = [1,2]

    snippet << "<p #{style}>" <<
    "<label>#{l(:field_num_of_cases)}</label>" <<
    text_field('requirements', 'id', :size => 10) << '</p>'
# << %{
#      <script>
#        new Form.Element.EventObserver('issue_tracker_id', function(element, value) {
#        if ($A(#{req_tracker_ids}).indexOf(Number(value)) >= 0)
#          $('requirement_issue_num_of_cases').up().show();
#        else
#          $('requirement_issue_num_of_cases').up().hide();
#        });
#      </script>
#    }

  end


    def controller_issues_new_after_save(context={ })
      params = context[:params]
      issue = context[:issue]
      req_id = params[:requirements][:id]
      req = Requirement.find(:first, :conditions => ['id = ? or req_id = ?',req_id,req_id])
      unless req.nil?
        issue.requirement_id = req.id
        Rails.logger.info "!!! controller_issues_new_after_save req #{issue.requirement_id}"
        issue.save!
      end
    end

    def controller_issues_edit_after_save(context={ })
      params = context[:params]
      issue = context[:issue]
      req_id = params[:requirements][:id]
      req = Requirement.find(:first, :conditions => ['id = ? or req_id = ?',req_id,req_id])
      unless req.nil?
        issue.requirement_id = req.id
        Rails.logger.info "!!! controller_issues_edit_after_save req #{issue.requirement_id}"
        issue.save!
      end
    end


  private

    def show_requirement_cases(issue, project)
      #requirement = Impasse::RequirementIssue.find(
      #  :first, :conditions => { :issue_id => issue.id },
      #  :include => :test_cases)
      snippet = ''
      return snippet unless issue.requirement_id
      Rails.logger.info "!!! showing requirement '#{issue.requirement_id}'"
      snippet << "<hr/><p><strong>Требования:</strong></p>"
      @requirements = [ Requirement.find( :first, :conditions => ['id = ? or req_id = ?', issue.requirement_id, issue.requirement_id ]) ]
      @requirements.each do |r|
          snippet << 
            "<p>" << "трассируется из " <<
            link_to("#{r.req_id} - #{r.text}", {
                      :controller => :requirements,
                      :action => :index,
                      :project_id => project,
                      :anchor => "testcase-1"
                    }) <<
            "</p>"
      end
      snippet
    end


end

