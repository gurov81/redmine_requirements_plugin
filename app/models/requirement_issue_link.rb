class RequirementIssueLink < ActiveRecord::Base
  unloadable

  has_many :requirements
  has_many :issues

  TYPE_TRACES_FROM  = "traces_from"
  TYPE_TRACES_TO    = "traces_to"

  TYPES = {
    TYPE_TRACES_FROM => { :name => :label_req_traces_from, :sym_name => :label_req_traces_from,
                          :order => 1, :sym => TYPE_TRACES_FROM },
    TYPE_TRACES_TO   => { :name => :label_req_traces_to, :sym_name => :label_req_traces_to,
                          :order => 2, :sym => TYPE_TRACES_TO, :reverse => TYPE_TRACES_FROM }
  }.freeze

  #validates_inclusion_of :link_type, :in => TYPES.keys
end
