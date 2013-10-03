class Requirement < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :issues, :class_name => 'RequirementIssueLink', :foreign_key => 'issue_link'
  has_many :requirements, :class_name => 'RequirementReqLink', :foreign_key => 'req_link'

  validates_presence_of :project_id, :req_id, :text
  validates_uniqueness_of :req_id, :scope => :project_id

  before_destroy { |record| Requirement.unlink_req(record.id) }

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

  def self.link_issue(rid,iid)
    Rails.logger.info "=== Requirement.link_issue req=#{rid} issue=#{iid}"
    req = Requirement.find(:first, :conditions => ['id = ? or req_id = ?',rid,rid])
    unless req.nil?
      link = RequirementIssueLink.new( :req => req.id, :issue_link => iid )
      link.save!
      Rails.logger.info "=== Requirement.link_issue req=#{req.id} ok"
    end
  end

  def self.unlink_issue(iid)
    Rails.logger.info "=== Requirement.unlink_issue issue=#{iid}"
    RequirementIssueLink.find(:all, :conditions => ['issue_link = ?',iid]).each do |link|
      link.destroy
    end
  end

  def self.unlink_req(rid)
    Rails.logger.info "=== Requirement.unlink_req req=#{rid}"
    RequirementIssueLink.find(:all, :conditions => ['req = ?',rid]).each do |link|
      link.destroy
    end
  end

  def self.linked_reqs(iid)
    Rails.logger.info "=== Requirement.linked_reqs issue=#{iid}"
    @ret = []
    RequirementIssueLink.find(:all, :conditions => ['issue_link = ?',iid]).each do |link|
      r = Requirement.find(:first,:conditions => ['id = ?', link.req])
      unless r.nil?
        Rails.logger.info "=== Requirement.linked_reqs req=#{r.id} #{r.req_id}"
        @ret << { :req => r, :direct => link.direct }
      end
    end
    @ret
  end

  def linked_issues
    Rails.logger.info "=== Requirement.linked_issues req=#{id}"
    @ret = []
    RequirementIssueLink.find(:all, :conditions => ['req = ?',id] ).each do |link|
      i = Issue.find(:first, :conditions => ['id = ?',link.issue_link] )
      unless i.nil?
        Rails.logger.info "=== Requirement.linked_issues issue=#{i.id}"
        @ret << { :issue => i, :direct => link.direct }
      end
    end
    @ret
  end

end
