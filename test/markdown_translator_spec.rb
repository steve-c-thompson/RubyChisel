require './lib/markdown_translator'


describe MarkdownTranslator do

  before do
    @translator = MarkdownTranslator.new
  end

  it "parses line without blank lines to paragraphs" do
    test_str = "This is the first line of the paragraph."
    expected = "<p>This is the first line of the paragraph.</p>"

    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses multiple lines without blank lines to paragraphs" do
    test_str = "This is the first line of the paragraph.\nThis is the second line of the same paragraph."
    expected = "<p>This is the first line of the paragraph. This is the second line of the same paragraph.</p>"

    expect(@translator.to_html(test_str)).to eq expected
  end


end
