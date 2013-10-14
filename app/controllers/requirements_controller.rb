require 'uri'

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

    linked_pages
  end

  def trace
    find_project
    index
    @issues = @project.issues
  end

  def show
    find_project
    @requirement = Requirement.find_any(params[:id])
    #Rails.logger.info "=== ReqCtrl:show:: #{@requirement.versions.inspect}"
  end

  def linked_pages
    @linked_pages = []
    @requirements.each do |r|
      r.url.scan(Regexp.new("(.+)(\#.+)")) { |l, r|
        l.scan(Regexp.new("(.+/wiki/)(.+)")) { |a, b|
          bb = URI.unescape(b)
          unless @linked_pages.count { |j| j[:url] == l } > 0
            @linked_pages << { :url => l, :name => bb }
          end
        }
      }
    end
    @linked_pages.uniq
  end

  def self.url(req)
    u = URI.unescape(req.url)
    u
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
