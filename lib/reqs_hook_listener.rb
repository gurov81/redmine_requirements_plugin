class ReqsHookListener < Redmine::Hook::ViewListener

  render_on :view_issues_show_description_bottom, :partial => "requirement_links/issue_reqs"
  #render_on :view_requirements_show_description_bottom, :partial => "show_requirements"

  def aview_projects_show_left(context={} )
    return content_tag("p", "Custom content added to the left")
  end

  def aview_projects_show_right(context={} )
    return content_tag("p", "Custom content added to the right")
  end

  #def view_issues_show_details_bottom(context={ })
  def aview_issues_show_description_bottom(context = {})
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

  def aview_issues_form_details_bottom(context = {})
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


    def acontroller_issues_new_after_save(context={ })
      params = context[:params]
      issue = context[:issue]
      req_id = params[:requirements][:id]

      Requirement.link_issue(req_id,issue.id) unless req_id.empty?
      Requirement.unlink_issue(issue.id) if req_id.empty?
    end

    def acontroller_issues_edit_after_save(context={ })
      params = context[:params]
      issue = context[:issue]
      req_id = params[:requirements][:id]

      Requirement.link_issue(req_id,issue.id) unless req_id.empty?
      Requirement.unlink_issue(issue.id) if req_id.empty?
    end


  private

    def show_requirement_cases(issue, project)
      #requirement = Impasse::RequirementIssue.find(
      #  :first, :conditions => { :issue_id => issue.id },
      #  :include => :test_cases)
      snippet = ''
      snippet << "<hr/><p><strong>Требования:</strong></p>"

      @reqs = Requirement.linked_reqs(issue.id)
      return snippet if @reqs.nil?

      @reqs.each do |r|
          snippet << "<p>трассируется из " if r[:direct] == true
          snippet << "<p>трассируется на " if r[:direct] == false
          req = r[:req]
          snippet << link_to("#{req.req_id} - #{req.text}", {
                      :controller => :requirements,
                      :action => :index,
                      :project_id => project,
                      :id => req.id
                    }) <<
            "</p>"
      end
      snippet
    end


end

