require 'wikicloth'
require 'nokogiri'

module MediawikiFormatter

  class WikiFormatter
    def initialize(text)
      @text = text
    end
    
    def to_html(&block)
      html = @text
      html.gsub!(/<(code|pre)\b\s+(?:class=['"]([\w\d]+)['"])?>([^<]*)<\/\1>/) do
        t, lang, code = $~.captures
        Redmine::SyntaxHighlighting.highlight_by_language(code, lang, false)
      end
      #html.gsub!(/<(code)\b(\s+[^>]*)>([^<]*)<\/\1>/, '<pre\2>\3</pre>')
      html = WikiCloth::Parser.new(:data => "__NOTOC__" + html).to_html(:noedit => true)

      html.gsub!(/<a\s/, "<a class='external'") # Add the `external` class to every link

      # only ruby 1.9 can support the group name:(?<groupname>\w+)
      #"John Smith".gsub /(?<name>.+)\s(?<family>.+)/ do
      #  p [$~[:name],$~[:family]]
      #end
      
      html

    rescue => e
      return("<pre>problem parsing wiki text: #{e.message}\n"+
             "original text: \n"+
             @text+
             "</pre>")
    end
  end
end
