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
