class RequirementsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :only => :index
  after_filter :update
  after_filter :destroy

  def index
    @requirements = []
    return if Requirement.all.nil?
    
    Requirement.all.each do |r|
      @requirements << r if r.project_id == params[:project_id]
    end
  end

  def trace
    find_project
    index
  end

  def add_link( context={} )
    rid = params[:requirement][:req_id]
    iid = params[:requirement][:issue_id]
    type = params[:requirement][:requirement_type]
    
    Rails.logger.info "!!!!!!!!!!!!! add iid=#{iid} rid=#{rid}"

    Requirement.link_issue(rid,iid,type)

    @issue = Issue.find( :first, :conditions => ['id = ?',iid] )

    respond_to do |format|
      format.html { 
        flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
        redirect_to issue_path(@issue)
      }
      format.api
    end
  end

  def del_link( context={} )
    Rails.logger.info "!!!!!!!!!!!!! delete_link context='#{context.inspect}'"
    Rails.logger.info "!!!!!!!!!!!!! delete_link params='#{params.inspect}'"

    rid = params[:requirement][:req_id]
    iid = params[:requirement][:issue_id]
    Rails.logger.info "!!!!!!!!!!!!! delete iid=#{iid} rid=#{rid}"

    Requirement.unlink_issue(rid,iid)

    @issue = Issue.find( :first, :conditions => ['id = ?',iid] )

    respond_to do |format|
      format.html { 
        flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
        redirect_to issue_path(@issue) #, :status => 301
      }
      format.api
    end
  end


  def self.collection_for_requirement_type_select
    values = RequirementIssueLink::TYPES
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def update
    Rails.logger.info "!!! UPDATE\n"
  end

  def destroy
    Rails.logger.info "!!! DESTROY\n"
  end
end
