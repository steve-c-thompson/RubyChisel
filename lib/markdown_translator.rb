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
    # build nodes for lines
    lines = input.split("\n\n")
    lines.each do |line|
      #puts "line: %#{line}%"
        @content_element_stack << build_top_level_node(line, @line_rules)
    end

    # builds nodes for each node's inner content
    # require 'pry'
    # binding.pry

    output = @content_element_stack.reduce("") do |str, node|
      str << node.build_html
    end

    output.gsub("\n", " ")
  end

  def build_top_level_node(input, rules)
    rule_index = 0
    # see if this content matches any rules
    rule_key = rules.keys().find do |key|
      rule_index = input.index(key)
      rule_index && rule_index >= 0
    end
    rule_index = 0 if !rule_index

    rule_end_length = 0
    if(rule_key)
      rule = rules[rule_key]

      rule_end = rule.md_close
      rule_end_length = rule_end.length
    end
    if(rule_key)
      rule = rules[rule_key]

      rule_end = rule.md_close

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

    st = rule_index + rule_key.length
    #require 'pry'
    #binding.pry
    content = input[st...end_index]

    node = ContentNode.new(rule)
    node.add_to_content(node.build_html_open)
    node.add_to_content(content)
    node.add_to_content(node.build_html_close)

    end_index += rule_end_length
    # Do something with the rest of the content
    # For multi-formatted things like <ul>, have to check
    # parent node
    if end_index < input.length
      input_sub = input[end_index..-1]
      new_node = build_top_level_node(input_sub, rules)
      node.add_to_content(new_node.content)
    end
    return node
  end

  # build a node from this string, checking for the start
  # of any other nodes within the node
  # closer is the parent's closing tag
  def build_inline_node(input, rules, closer=nil)

    # check what this text starts with from rules
    rule_index = 0
    rule_key = rules.keys().find do |key|
      rule_index = input.index(key)
      rule_index && rule_index >= 0
    end
    # require 'pry'
    # binding.pry
    rule_index = 0 if !rule_index

    end_index = 0
    rule = nil
    if(rule_key)
      rule = rules[rule_key]

      rule_end = rule.md_close
      # TODO: scan for new rule or end of this rule
      # and use substrings

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

    st = rule_index + rule_key.length
    #require 'pry'
    #binding.pry
    content = input[st...end_index]

    node = ContentNode.new(rule)
    node.add_to_content(content)


    return node
  end


end
