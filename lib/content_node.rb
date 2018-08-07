class ContentNode
  attr_reader :rule, :content

  def initialize(rule)
    @rule = rule
    @content = ""
    @nodes = []
  end

  def add_to_content(c)
    @content << c
  end

  def add_node(el)
    @nodes << el
  end

  def build_html_open
    if(@rule)
      @rule.html_open
    else
      ""
    end
  end

  def build_html_close
    if(@rule)
      @rule.html_close
    else
      ""
    end
  end

  def build_html
    build_html_open + @content + build_html_close
  end
end
