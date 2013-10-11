module RequirementsHelper

  def link_to_requirement(req)
    baseurl = Redmine::Utils.relative_url_root
    src = baseurl + "/requirements/show/#{req.id}?project_id=#{@project.id}"

    link_to( "#{req.req_id} - #{req.text.truncate(100)}", src )
  end

  def self.url_of_requirement(req,project=nil)
    #src = Redmine::Utils.relative_url_root
    src = ""
    src += "/requirements/show/#{req.id}"
    src += "?project_id=#{project.id}" unless project.nil?
    src
  end
end
