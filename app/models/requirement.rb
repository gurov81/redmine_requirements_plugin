class Requirement < ActiveRecord::Base
  unloadable

  belongs_to :project
  #has_many :requirement, :class_name => 'Issue', :foreign_key => 'requirement_id'
  has_many :issues

  validates_presence_of :project_id, :req_id, :text
  validates_uniqueness_of :req_id, :scope => :project_id

  def ==(obj)
    return false unless self.project_id == obj.project_id
    return self.req_id == obj.req_id
  end

  def self.find_or_create(p_id, req_id, text)
    req = Requirement.find(:first,
      :conditions => ['project_id = ? and req_id = ? and text = ?',
        p_id, req_id, text ])

    unless req
      req = Requirement.new
      req.project_id = p_id
      req.req_id = req_id
      req.text = text
      #Rails.logger.info "=== Requirement create id='#{req.id}' pid='#{p_id}' rid='#{req_id}' text='#{text}'" if logger
    end
    return req
  end

  def links_to
    @links = []
    @links = Issue.find(:first, :conditions => ['requirement_id = ?',id] )
    return @links
    #return [1,2,3]
  end
end
