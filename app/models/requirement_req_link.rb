class RequirementReqLink < ActiveRecord::Base
  unloadable

  has_many :requirements
end
