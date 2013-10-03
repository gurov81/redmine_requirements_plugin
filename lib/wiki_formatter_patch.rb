require_dependency "redmine/wiki_formatting/textile/formatter"

module WikiFormatterPatch
  def self.included(base) # :nodoc:
    base.send(:include, WikiFormatterMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end
end

module WikiFormatterMethods
  Redmine::WikiFormatting::Textile::Formatter::RULES << :inline_requirements

  private

  def inline_requirements(text)
    #Rails.logger.info "inline requirements '#{text}'"
    baseurl = Redmine::Utils.relative_url_root
    src = baseurl + "/requirements/"

    text.gsub!(Regexp.new("<br />"), "<br/>")

    text.scan(Regexp.new("(REQ[-]?[0-9.]+)(\\s+.+?)(<br/>|</p>)")) { |r, t|
      #Rails.logger.info "scan:: req='#{r}' text='#{t}' id=#{param}"
      
      #req = Requirement.find_or_create(@project,r,t)
      #req.save!
    }

    text.gsub!(Regexp.new("(REQ[-]?)([0-9.]+)(\\s+.+?)(<br/>|</p>)"),
      #"<a name=\"\\1\\2\"></a>\\2\\3<a href=\"#\\1\\2\" class=\"wiki-anchor\">&para;</a>\\4" )
      "<a name=\"\\1\\2\"/><a href=\""+src+"\\1\\2\" >\\2\\3</a><a href=\"#\\1\\2\" class=\"wiki-anchor\">&para;</a>\\4" )
    #Rails.logger.info "   => '#{text}'"

  end
end
