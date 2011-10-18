# Redmine Markdown formatter
require 'redmine'
require 'dispatcher'

require_dependency 'markup_hook'

RAILS_DEFAULT_LOGGER.info 'Starting Markup language formatters for Redmine'

Dispatcher.to_prepare :redmine_markups do
    unless Project.included_modules.include?(MarkupProjectPatch)
        Project.send(:include, MarkupProjectPatch)
    end
end

Redmine::Plugin.register :redmine_markups do
  name 'Markups language formatters'
  author 'Riceball lEE'
  author_url "https://github.com/snowyu"
  url "https://github.com/snowyu/redmine_js_syntax_highlighter"
  description 'This provides Markdown, wikimedia  etc multiple wiki formats'
  version '0.0.1'

  wiki_format_provider 'markdown', MarkdownFormatter::WikiFormatter, MarkdownFormatter::Helper
  wiki_format_provider 'mediawiki', MediawikiFormatter::WikiFormatter, MediawikiFormatter::Helper
  wiki_format_provider 'rdoc', RdocFormatter::WikiFormatter, RdocFormatter::Helper
  wiki_format_provider 'textile', TextileFormatter::WikiFormatter, TextileFormatter::Helper
end
