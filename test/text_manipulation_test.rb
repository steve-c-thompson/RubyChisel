require './lib/text_manipulation'
require 'minitest/autorun'
require 'minitest/pride'

class TestClass
  include TextManipulation

end

class TextManipulationTest < Minitest::Test

  def setup
    @tm = TestClass.new
  end


  def test_is_number_returns_true_for_single_digits
    input = "0"

    10.times do
      assert @tm.is_number(input)
      input = input.next
    end
  end

  def test_is_number_returns_false_for_mixed_digit_and_alpha
    refute @tm.is_number("12a3")
    refute @tm.is_number("1 ")
    refute @tm.is_number("a1")
  end

end
