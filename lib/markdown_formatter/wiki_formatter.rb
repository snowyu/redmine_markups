require 'redcarpet'

module MarkdownFormatter
  class HTMLWithHighlighter < Redcarpet::Render::HTML 
    def block_code(code, language)
      #Albino.safe_colorize(code, language)
      #"<pre class=\"brush: #{language};\">#{code}</pre"
      Redmine::SyntaxHighlighting.highlight_by_language(code, language);
    end
  end

  class WikiFormatter
    def initialize(text)
      @text = text
    end
    
    def to_html(&block)
      #options = [:filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
      #markdown = Redcarpet.new(@text, *options)
      markdown = Redcarpet::Markdown.new(HTMLWithHighlighter.new,
          :no_intra_emphasis => true,
          :fenced_code_blocks => true,
          :strikethrough => true,
          :space_after_headers => true,
          :superscript => true,
          :autolink => true
          )
      html = markdown.render(@text)
      html.gsub!(/<a\s/, "<a class='external' ") # Add the `external` class to every link
      html.gsub(/&#(\d+);/) do
        ascii = Integer($~.captures[0])
        ascii.chr
      end
      #doc = Nokogiri::HTML(html).css('body').first.children 
      #doc.search("//pre/code[@class]").each do |pre|
      #  p pre[:class]
      #  pre.replace Redmine::SyntaxHighlighting.highlight_by_language(pre.text.rstrip, pre[:class])
      #end
      #p doc.to_s
      #doc.to_s
    rescue => e
      return("<pre>problem parsing wiki text: #{e.message}\n"+
             "original text: \n"+
             @text+
             "</pre>")
    end
  end
end
