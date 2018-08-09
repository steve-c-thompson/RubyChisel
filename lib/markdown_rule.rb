class MarkdownRule
  attr_reader :md_open, :md_close, :html_open, :html_close, :html_group_open, :html_group_close

  def initialize(md_open, md_close, html_open, html_close, html_group_open="", html_group_close="")
    @md_open = md_open
    @md_close = md_close
    @html_open = html_open
    @html_close = html_close
  end

end
