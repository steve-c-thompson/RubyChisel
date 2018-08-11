require_relative 'markdown_rule'
require_relative 'text_manipulation'

class MarkdownTranslator

  include TextManipulation

  def initialize
    # rules for lines
    @top_level_rules = ["* ", "#"]

    @inline_rules = {
      '**' => MarkdownRule.new('**', '**', '<strong>', '</strong>'),
      '*' => MarkdownRule.new('*', '*', '<em>', '</em>')
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
      output << build_top_level_content(lines)
    end

    #p output

    rule_stack = []   # stack for rules that are open
    old_output = ""
    while(old_output != output)
      old_output = output
      output = build_inline_content(old_output, @inline_rules, rule_stack)
    end
    output
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

  def handle_ol_lists(lines, index, output)
    output << "<ol>"
    lines_list = gather_numeric_lines(lines.slice(index..-1))

    lines_list.each do |l|
      char_index_after_num_and_space = l.index('.') + 2
      char_index_after_num_and_space -= 1 if char_index_after_num_and_space > l.length
      arr = do_substitution_to_index(l, 0, char_index_after_num_and_space , "<li>")

      output << arr[0] << arr[1]
      output << "</li>"
    end

    output << "</ol>"

    lines_list.size()
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

  def gather_numeric_lines(lines)
    line_list = []

    lines.each do |l|
      if(check_if_number_start(l))
        line_list << l
      else
        break;
      end
    end

    line_list
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
  def build_top_level_content(lines)

    output = ""
    i = 0
    while i < lines.length do
      if(lines[i].start_with? "#")
        output << handle_header(lines[i])
        i += 1
      elsif(lines[i].start_with? "* ")
        num_lines = handle_ul_list(lines, i, output)
        i += num_lines
      elsif(check_if_number_start(lines[i]))
        num_lines = handle_ol_lists(lines, i, output)
        i += num_lines
      else
        # paragraph
        num_lines = handle_paragraph(lines, i, output)
        i += num_lines
      end
    end

    output
  end

  # Switch this to only using input and return value, no buffer
  def build_inline_content(input, rule_set, rule_stack)

    #p "build_inline_content with rule_set #{rule_set.keys()}"

    #rule_enum = rule_set.each # for rewinding
    #rule_enum.each do |rule, markdown_obj|

    # Doing manual iteration here so that the loop can start over
    # Tried rewind with inside each, but it didn't work,
    # and using rescue StopIteration (or any exception mechanism)
    # to control program flow isn't the best idea.
    i = 0
    while(i < rule_set.size)
      rule = rule_set.keys()[i]
      markdown_obj = rule_set[rule]
      i += 1
      #p "checking for rule #{rule}"
      new_rule_idx = input.index(markdown_obj.md_open)

      # check for an old rule on the stack to close
      old_rule_close_idx = nil
      if(rule_stack.length > 0)
        old_rule = rule_stack.last
        old_rule_close_idx = input.index(old_rule.md_close)
      end

      # rule on the stack that needs closing
      if(old_rule_close_idx)
        # if there's a new rule, see if it comes after close
        if(new_rule_idx == nil || new_rule_idx >= old_rule_close_idx)
          #p "old rule found at #{old_rule_close_idx}: #{old_rule} and new_rule_idx is #{new_rule_idx}"
          # if so, close the old rule
          old_rule = rule_stack.pop

          buf = do_substitution_to_index(input, old_rule_close_idx, old_rule.md_close.length, old_rule.html_close)
          output_buffer = buf[0]
          input = buf[1]

          input = output_buffer + input
          # reset new_rule_idx to avoid processing
          # rule_enum.rewind
          #p "old rule #{old_rule.md_close} closed"

          new_rule_idx = nil
        end
      end
      if(new_rule_idx)
        #p "new rule #{rule} at #{new_rule_idx} with rules #{rule_set.keys()}"
        #p "Processing new rule #{rule}"
        # put a new rule on the stack of rules
        rule_stack.push markdown_obj;
        # create a subset of rules
        rule_subset = rule_set.reject do |key, value|
          rule == key
        end

        buf = do_substitution_to_index(input, new_rule_idx, markdown_obj.md_open.length, markdown_obj.html_open)
        output_buffer = buf[0]
        input = buf[1]

        # recursive call with subset of rules
        input = output_buffer + build_inline_content(input, rule_subset, rule_stack)
        # rewind to start over will all rules
        #rule_enum.rewind
        i = 0
        #p "Rewinding enum to start over after rule #{rule}"
      end
    end
    #p "end build_inline_content with #{input} and rule_stack #{rule_stack}"
    return input
  end

  def check_if_number_start(str)
    dot_index = str.index(". ")
    result = false
    if(dot_index && dot_index > 0)
      # cannot see if we can get a number from this text
      # because this could still return zero on failure
      #num = str[0...dot_index].to_i
      result = is_number(str[0...dot_index])
    end
    result
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
end
