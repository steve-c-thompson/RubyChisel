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
    chunks = input.split("\n\n")
    output = ""
    chunks.each do |chunk|
      output += build_top_level_content(chunk)
    end

    output

    # builds nodes for each node's inner content
    # require 'pry'
    # binding.pry

    # output = @content_element_stack.reduce("") do |str, node|
    #   str << node.build_html
    # end

    #output.gsub("\n", " ")
  end

  # This handles grouped lines and assumes
  # headers can follow paragraph lines
  def build_top_level_content(chunk)
    # eat any whitespace
    chunk.strip!
    lines = chunk.split("\n")

    handled_arr = []  # 2D array of whether lines have been handled

    i = 0
    while i < lines.length do
      handled = false
      if(lines[i].start_with? "#")
        lines[i] = header(lines[i])
        handled = true
      end
      handled_arr[i] = [handled, lines[i]]
      i += 1
    end

    # see which lines have not been handled
    # and join in order
    groups = handled_arr.chunk do |arr|
      arr[0]
    end

    translated = []
    # now iterate through groups
    # handle group *
    # handle group >
    # handle group unhandled
    grouped_lines = groups.each do |handled, array|
      if(handled == false)
        selected = array.map do |inner|
          inner[1]
        end
        # TODO: change the first and last handled?
        joined = "<p>" + selected.join(' ') + "</p>"
        translated << joined
      else
        translated << array.flatten()[1]
      end
    end

    translated.join('')
  end

  # could really just use gsub here, except that means RE's
  def header(line)
    # number of #'s
    pound_len = line.index(" ")
    pound_len = 1 if !pound_len # in case this is just "#" in a line
    len_str = pound_len.to_s
    output = "<h" + len_str + ">"
    if(line.length > 1)
      output += line[pound_len + 1..-1]
    end
    output += "</h" + len_str + ">"

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
