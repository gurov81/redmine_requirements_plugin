class RequirementIssueLink < ActiveRecord::Base
  unloadable

  has_many :requirements
  has_many :issues
end
