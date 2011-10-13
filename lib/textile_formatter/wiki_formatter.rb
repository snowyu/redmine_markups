require 'redcloth3'

module TextileFormatter

  class WikiFormatter < RedCloth3
        include ActionView::Helpers::TagHelper

        # auto_link rule after textile rules so that it doesn't break !image_url! tags
        RULES = [:textile, :block_markdown_rule, :inline_auto_link, :inline_auto_mailto]

        def initialize(*args)
          super
          self.hard_breaks=true
          self.no_span_caps=true
          self.filter_styles=true
        end

        def to_html(*rules)
          @toc = []
          super(*RULES).to_s
        end

      private

        # Patch for RedCloth.  Fixed in RedCloth r128 but _why hasn't released it yet.
        # <a href="http://code.whytheluckystiff.net/redcloth/changeset/128">http://code.whytheluckystiff.net/redcloth/changeset/128</a>
        def hard_break( text )
          text.gsub!( /(.)\n(?!\n|\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks
        end

        # { OFFTAGS }
        # (?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(?=<\/?#{ OFFTAGS }\W|\Z
        #OFFTAG_MATCH = /<#{ OFFTAGS }\b([^>]*)?>([^<]*)<\/\1>/i
        
        def rip_offtags( text )
          if text =~ /<.*>/
              ## strip and encode <pre> content
              codepre, used_offtags = 0, {}
              text.gsub!( OFFTAG_MATCH ) do |line|
                  if $3
                      offtag, aftertag = $4, $5
                      codepre += 1
                      used_offtags[offtag] = true
                      if codepre - used_offtags.length > 0
                          htmlesc( line, :NoQuotes )
                          @pre_list.last << line
                          line = ""
                      else
                          htmlesc( aftertag, :NoQuotes ) if aftertag
                          line = "<redpre##{ @pre_list.length }>"
                          $3.match(/<#{ OFFTAGS }([^>]*)>/)
                          tag = $1
                          $2.to_s.match(/(class\=\S+)/i)
                          tag << " #{$1}" if $1
                          @pre_list << "<#{ tag }>#{ aftertag }"
                      end
                  elsif $1 and codepre > 0
                      if codepre - used_offtags.length > 0
                          htmlesc( line, :NoQuotes )
                          @pre_list.last << line
                          line = ""
                      end
                      if codepre == 1
                        @pre_list.last << "#{$1}"
                        line = line[$1.length..-1]
                      end
                      codepre -= 1 unless codepre.zero?
                      used_offtags = {} if codepre.zero?
                  end 
                  line
              end
          end
          text
=begin
            if text =~ /<.*>/
                ## strip and encode <pre> content
                codepre, used_offtags = 0, {}
                text.gsub!( OFFTAG_MATCH ) do |line|
                    tag, params, body = $~.captures
                    if tag
                        htmlesc( body, :NoQuotes ) if body and tag != 'notextile'
                        line = "<redpre##{ @pre_list.length }>"
                        @pre_list << "<#{tag}#{params}>#{body}</#{tag}>"
                    end 
                    line
                end
            end
            text
=end
        end
        # Patch to add code highlighting support to RedCloth
        def smooth_offtags( text )
          unless @pre_list.empty?
            ## replace <pre> content
            text.gsub!(/<redpre#(\d+)>/) do
              content = @pre_list[$1.to_i]
              if content.match(/<(code|pre)\b\s+class="(\w+)">\s?(.+)<\/\1>/m)
                content =
                  Redmine::SyntaxHighlighting.highlight_by_language($3, $2, false)
              end
              content
            end
          end
        end

        AUTO_LINK_RE = %r{
                        (                          # leading text
                          <\w+.*?>|                # leading HTML tag, or
                          [^=<>!:'"/]|             # leading punctuation, or
                          ^                        # beginning of line
                        )
                        (
                          (?:https?://)|           # protocol spec, or
                          (?:s?ftps?://)|
                          (?:www\.)                # www.*
                        )
                        (
                          (\S+?)                   # url
                          (\/)?                    # slash
                        )
                        ((?:&gt;)?|[^\w\=\/;\(\)]*?)               # post
                        (?=<|\s|$)
                       }x unless const_defined?(:AUTO_LINK_RE)

        # Turns all urls into clickable links (code from Rails).
        def inline_auto_link(text)
          text.gsub!(AUTO_LINK_RE) do
            all, leading, proto, url, post = $&, $1, $2, $3, $6
            if leading =~ /<a\s/i || leading =~ /![<>=]?/
              # don't replace URL's that are already linked
              # and URL's prefixed with ! !> !< != (textile images)
              all
            else
              # Idea below : an URL with unbalanced parethesis and
              # ending by ')' is put into external parenthesis
              if ( url[-1]==?) and ((url.count("(") - url.count(")")) < 0 ) )
                url=url[0..-2] # discard closing parenth from url
                post = ")"+post # add closing parenth to post
              end
              tag = content_tag('a', proto + url, :href => "#{proto=="www."?"http://www.":proto}#{url}", :class => 'external')
              %(#{leading}#{tag}#{post})
            end
          end
        end

        # Turns all email addresses into clickable links (code from Rails).
        def inline_auto_mailto(text)
          text.gsub!(/([\w\.!#\$%\-+.]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+)/) do
            mail = $1
            if text.match(/<a\b[^>]*>(.*)(#{Regexp.escape(mail)})(.*)<\/a>/)
              mail
            else
              content_tag('a', mail, :href => "mailto:#{mail}", :class => "email")
            end
          end
        end
  end
end
