require_relative 'markdown_rule'
require_relative 'content_node'

class MarkdownTranslator

  def initialize
    # rules for lines
    @top_level_rules = ["* ", "#"]

    @line_rules = {
      # '###### ' => MarkdownRule.new('###### ', "\n", "<h6>", "</h6>"),
      # '##### ' => MarkdownRule.new('##### ', "\n", "<h5>", "</h5>"),
      # '#### ' => MarkdownRule.new('#### ', "\n", "<h4>", "</h4>"),
      # '### ' => MarkdownRule.new('### ', "\n", "<h3>", "</h3>"),
      # '## ' => MarkdownRule.new('## ', "\n", "<h2>", "</h2>"),
      # '# ' => MarkdownRule.new('# ', "\n", "<h1>", "</h1>"),
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
      # eat any whitespace
      chunk.strip!
      lines = chunk.split("\n")
      build_top_level_content(lines, output)
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

  def handle_ul_list(lines, index, output)
    output << "<ul>"
    # gather matching lines
    line_list = gather_matching_lines(lines.slice(index..-1), "* ")
    # process with li's

    line_list.each do |l|
      output << l.sub("* ", "<li>")
      output << "</li>"
    end
    output << "</ul>"

    line_list.size()
  end

  def handle_paragraph(lines, index, output)
    output << "<p>"
    # gather non-matching lines
    line_list = gather_nonmatching_lines(lines.slice(index..-1),
  @top_level_rules)
    # add all and replace \n with space
    output << line_list.join(' ')
    output << "</p>"
    line_list.size()
  end

  def gather_matching_lines(lines, rule)
    line_list = []

    lines.each do |l|
      if(l.start_with? rule)
        line_list << l
      else
        break
      end
    end
    line_list
  end

  def gather_nonmatching_lines(lines, rules)
    line_list = []
    lines.each do |l|
      match = rules.any? do |r|
        l.start_with? r
      end
      if(match)
        break;
      else
        line_list << l
      end
    end

    line_list
  end

  # This handles grouped lines and assumes
  # headers can follow paragraph lines
  def build_top_level_content(lines, output)

    i = 0
    while i < lines.length do
      if(lines[i].start_with? "#")
        output << handle_header(lines[i])
        i += 1
      elsif(lines[i].start_with? "* ")
        num_lines = handle_ul_list(lines, i, output)
        i += num_lines
      else
        # paragraph
        num_lines = handle_paragraph(lines, i, output)
        i += num_lines
      end
    end

    output
  end

  def check_if_number_start(str)
    first_space = str.index(". ")
    if(first_space && first_space > 0)
      # see if we can get a number from this text
      num = str[0...first_space].to_i
      # this could be zero for invalid, or an actual number
    end

  end

  # could really just use gsub here, except that means RE's
  def handle_header(line)
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
