require_relative 'markdown_rule'
require_relative 'content_node'

class MarkdownTranslator

  def initialize
    # rules for lines
    @line_rules = {
      '###### ' => MarkdownRule.new('###### ', "\n", "<h6>", "</h6>"),
      '##### ' => MarkdownRule.new('##### ', "\n", "<h5>", "</h5>"),
      '#### ' => MarkdownRule.new('#### ', "\n", "<h4>", "</h4>"),
      '### ' => MarkdownRule.new('### ', "\n", "<h3>", "</h3>"),
      '## ' => MarkdownRule.new('## ', "\n", "<h2>", "</h2>"),
      '# ' => MarkdownRule.new('# ', "\n", "<h1>", "</h1>"),
      "" => MarkdownRule.new("", "", "<p>", "</p>")
    }
    @content_element_stack = []
  end

  # read string and see what it starts with, then use rule to read to end, or end of input
  # will have to strip \n from content to match expected output
  def to_html(input)

    input = trim_leading_newlines(input)
    # build nodes for lines
    lines = input.split('\n\n')

    lines.each do |line|
        @content_element_stack << build_node(line, @line_rules)
    end

    # builds nodes for each node's inner content
    # require 'pry'
    # binding.pry

    output = @content_element_stack.reduce("") do |str, node|
      str << node.build_html
    end

    output.gsub("\n", " ")
  end

  def trim_leading_newlines(input)
    # eat any leading \n
    i = 0
    while (i < input.length) do
      c = input[i]
      if(i != '\n')
        break;
      end
      i += 1
    end
    input = input[i...input.length]
  end

  # build a node from this string, checking for the start
  # of any other nodes within the node
  # closure_stack is any outer rules that could be closing
  def build_node(input, rules)

    # check what this text starts with from rules
    new_rule_index = 0
    rule_key = rules.keys().find do |key|
      new_rule_index = input.index(key)
      new_rule_index && new_rule_index >= 0
    end
    # require 'pry'
    # binding.pry
    new_rule_index = 0 if !new_rule_index

    end_index = 0
    rule = nil
    if(rule_key)
      rule = rules[rule_key]

      rule_end = rule.md_close
      # TODO: scan for other new rules
      # find where to end
      if(rule_end.length > 0)
        idx = input.index(rule_end)
        if(idx)
          end_index = idx
        else
          end_index = input.length
        end
      else
        end_index = input.length
      end

    else
      end_index = input.length
    end

    st = new_rule_index + rule_key.length
    #require 'pry'
    #binding.pry
    content = input[st...end_index]

    node = ContentNode.new(rule)
    node.add_to_content(content)

    return node
  end


end
