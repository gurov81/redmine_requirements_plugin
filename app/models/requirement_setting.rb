class RequirementSetting < ActiveRecord::Base
  unloadable
  belongs_to :project

  def self.find_or_create(pj_id)
    setting = RequirementSetting.find(:first, :conditions => ['project_id = ?', pj_id])
    unless setting
      setting = RequirementSetting.new
      setting.project_id = pj_id
      setting.save!
    end
    return setting
  end

  def self.prefixes(pj_id)
    setting = find_or_create(pj_id)
    l = setting.prefix_list
    #Rails.logger.info "=== RequirementSetting: id='#{pj_id}' pref='#{l.inspect}'"
    l.gsub!(",","|") unless l.nil?
    return l
  end
end
