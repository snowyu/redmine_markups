#require 'rdoc'
require "rdoc/markup"
require "rdoc/markup/to_html"
require 'nokogiri'

module RdocFormatter

  class WikiFormatter
    def initialize(text)
      @text = text
    end
    
    def to_html(&block)
      html = @text
      rdoc = ::RDoc::Markup::ToHtml.new
      html = rdoc.convert(html)
      html.gsub!(/<(code|pre)\b[^>]*>(?:```([\w\d]+))?([^<]*)<\/\1>/) do
        t, lang, code = $~.captures
        Redmine::SyntaxHighlighting.highlight_by_language(code, lang, false)
      end
      html.gsub(/<a\s/, "<a class='external'") # Add the `external` class to every link
    rescue => e
      return("<pre>problem parsing wiki text: #{e.message}\n"+
             "original text: \n"+
             @text+
             "</pre>")
    end
  end
end
