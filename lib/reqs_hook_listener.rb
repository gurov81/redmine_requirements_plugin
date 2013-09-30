class ReqsHookListener < Redmine::Hook::ViewListener
  def view_projects_show_left(context={} )
    return content_tag("p", "Custom content added to the left")
  end
  def view_projects_show_right(context={} )
    return content_tag("p", "Custom content added to the right")
  end
end

