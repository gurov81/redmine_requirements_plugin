# Wiki Extensions plugin for Redmine
# Copyright (C) 2009  Haruyuki Iida
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class RequirementsSettingsController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project, :authorize, :find_user

  def update
    setting = RequirementSetting.find_or_create @project.id
    begin
      setting.transaction do
        setting.prefix_list = params[:prefix_list]
        setting.save!
      end
      flash[:notice] = l(:notice_successful_update)
    rescue
      flash[:error] = "Updating failed."
    end
    redirect_to :controller => 'projects', :action => "settings", :id => @project, :tab => 'requirements'
  end

  private
  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
    #Rails.logger.info "=== RequirementSettings: project='#{@project.id}'"
  end

  def find_user
    @user = User.current
  end
end
