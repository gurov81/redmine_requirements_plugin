class Requirement < ActiveRecord::Base
  unloadable
  self.locking_column = 'version'

  belongs_to :project
  belongs_to :user

  has_many :issues, :class_name => 'RequirementIssueLink', :foreign_key => 'issue_link'
  has_many :requirements, :class_name => 'RequirementReqLink', :foreign_key => 'req_link'

  validates_presence_of :project_id, :req_id, :text, :version, :updated_at, :user_id
  #validates_uniqueness_of :req_id, :scope => :project_id

  acts_as_versioned


  before_destroy { |record| Requirement.unlink_req(record.id) }

  class Version

    belongs_to :project
    belongs_to :user
    has_many :issues, :class_name => 'RequirementIssueLink', :foreign_key => 'issue_link'
    has_many :requirements, :class_name => 'RequirementReqLink', :foreign_key => 'req_link'
    attr_protected :data

    acts_as_event :title => Proc.new { |o| o.describe_event },
                :author => Proc.new { |o| o.author },
                #:description => Proc.new { |o| "hehe 13" }, #o.text },
                :description => :text,
                :datetime => :updated_at,
                :url => Proc.new { |o| {:controller => 'requirements', :action => 'show', :id => o.requirement_id, :only_path => true, :project_id => o.project_id} }

    acts_as_activity_provider :type => 'requirements',
                            #:permission => :view_requirements,
                            :timestamp => "#{Requirement.versioned_table_name}.updated_at",
                            :author_key => "#{Requirement.versioned_table_name}.user_id",
                            :find_options => { 
                              :select => "#{Requirement.versioned_table_name}.*",
                              #:where => "#{Requirement.versioned_table_name}.project_id = #{project.identifier}",
                              #:joins => "LEFT JOIN #{Project.table_name} ON #{Project.table_name}.identifier = #{Requirement.versioned_table_name}.project_id",
                              :include => [:project, :requirements]
                            }
                            #:find_options => {:joins => "LEFT JOIN #{Requirement.table_name} ON #{Requirement.table_name}.id = #{Requirement.table_name}.project_id" }
                            #:find_options => {:include => {:wiki_page => {:wiki => :project}}}

    def author
      User.find(user_id) #User.current
    end

    def project
      Project.find_by_name(project_id)
    end

    def self.visible(user,options)
      self
      #Rails.logger.info "zzz #{options.inspect}"
      #!user.nil? && user.allowed_to?(:view_requirements, options[:project])
    end

    def describe_event
      if version == 1
        "#{l(:notify_req_added)} #{req_id}"
      elsif version == 0
        "#{l(:notify_req_deleted)} #{req_id}"
      else
        "#{l(:notify_req_changed)} #{req_id}"
      end
    end

  end

  def author
    User.find(user_id) #User.current
  end

  def created_on
    updated_at
  end



  def ==(obj)
    return false unless self.project_id == obj.project_id
    return self.req_id == obj.req_id
  end

  def self.find_by_id(i)
    return Requirement.find(:first,:conditions=>['id = ?',i])
  end

  def self.find_any(i)
    return Requirement.find(:first,:conditions=>['id = ? or req_id = ?',i,i])
  end

  def self.find_or_create(p_id, req_id, text, url)
    req = Requirement.find(:first,
      :conditions => ['project_id = ? and req_id = ? and text = ?',
        p_id, req_id, text ])

    unless req
      req = Requirement.new
      req.project_id = p_id
      req.req_id = req_id
      req.text = text
      req.url = url
      req.updated_at = Time.now
      req.user_id = User.current.id
      #Rails.logger.info "=== Requirement create id='#{req.id}' pid='#{p_id}' rid='#{req_id}' text='#{text}'" if logger
    end
    return req
  end

  def self.link_issue(rid,iid,type)
    Rails.logger.info "=== Requirement.link_issue req=#{rid} issue=#{iid}"
    req = Requirement.find(:first, :conditions => ['id = ? or req_id = ?',rid,rid])
    unless req.nil?
      t = (type == "traces_from" ? 1 : 2)
      link = RequirementIssueLink.new( :req => req.id, :issue_link => iid, :link_type => t )
      link.save!
      Rails.logger.info "=== Requirement.link_issue req=#{req.id} ok"
    end
  end

  def self.unlink_issue(rid,iid)
    Rails.logger.info "=== Requirement.unlink_issue req=#{rid} issue=#{iid}"
    RequirementIssueLink.destroy_all( :req => rid, :issue_link => iid )
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
        @ret << { :req => r, :link_type => link.link_type }
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
        @ret << { :issue => i, :link_type => link.link_type }
      end
    end
    @ret
  end

  def linked_with_issue?(issue)
    if RequirementIssueLink.find(:first,:conditions => ['req = ? and issue_link = ?',id,issue.id]).nil?
      return false
    end
    return true
  end

  def issue_progress
    links = linked_issues
    closed_issues = 0
    done_ratio = 0
    links.each do |link|
      if link[:issue].closed?
        closed_issues += 1
        done_ratio += link[:issue].done_ratio #fixme +100 ?
      else
        done_ratio += link[:issue].done_ratio
      end
    end
    percent = 0
    percent = (done_ratio.to_f / links.count) unless links.empty?

    @ret = { :closed => closed_issues, :total => links.count, :percent => percent }
    @ret
  end

end
