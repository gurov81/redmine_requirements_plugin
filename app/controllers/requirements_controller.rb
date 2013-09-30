class RequirementsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :only => :index

  def index
    #@project = Project.find(params[:project_id])
    @requirements = Requirement.all
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end
end
