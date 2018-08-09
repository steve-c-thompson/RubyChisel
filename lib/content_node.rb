class ContentNode
  attr_reader :rule, :content

  def initialize(rule)
    @rule = rule
    @content = []
  end

  # Can add Strings or other ContentNodes
  def add_to_content(c)
    @content << c
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
    to_s
  end

  def to_s
     @content.join()
  end
end
