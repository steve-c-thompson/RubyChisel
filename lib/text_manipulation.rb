module TextManipulation

  def is_number(input)
    result = true
    # check the ordinal value of each part of input
    result = input.chars.all? do |c|
      num = c.ord
      num >= 48 && num <= 57
    end

    result
  end

  # Substitute to index, return [sub, rest_of_input]
  def do_substitution_to_index(input, idx, subst_len, replacement)
    front = input[0...idx]
    subst_end = idx + subst_len
    output_buffer = ""
    output_buffer << front
    output_buffer << replacement  #substitution

    input = input[subst_end..-1]
    [output_buffer, input]
  end
end
