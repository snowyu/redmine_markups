module Markup
  class Hook  < Redmine::Hook::ViewListener
       def view_projects_form(context = {})
           row = ''
           row << label_tag('project[text_formatting]', l(:setting_text_formatting))
           row << select_tag('project[text_formatting]', project_text_formatting_options_for_select(context[:project] ? context[:project][:text_formatting] : nil))
           content_tag(:p, row)
       end
     
       private
       
           def project_text_formatting_options_for_select(selected = nil)
               options = [[ l(:label_default_format), '' ]] + Redmine::WikiFormatting.format_names.collect{|name| [name, name.to_s]}
  
               options_for_select(options, selected)
           end
  
  end
end