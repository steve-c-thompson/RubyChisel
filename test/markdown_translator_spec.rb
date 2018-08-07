require './lib/markdown_translator'


describe MarkdownTranslator do

  before do
    @translator = MarkdownTranslator.new
  end

  xit "parses line without blank lines to paragraphs" do
    test_str = "This is the first line of the paragraph."
    expected = "<p>This is the first line of the paragraph.</p>"

    expect(@translator.to_html(test_str)).to eq expected
  end

  xit "parses multiple lines without blank lines to paragraphs" do
    test_str = "This is the first line of the paragraph.\nThis is the second line of the same paragraph."
    expected = "<p>This is the first line of the paragraph. This is the second line of the same paragraph.</p>"

    expect(@translator.to_html(test_str)).to eq expected
  end

  xit "parses h1 headers" do
    test_str = '# This is a header'
    expected = '<h1>This is a header</h1>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  xit "parses h2 headers" do
    test_str = '## This is a header'
    expected = '<h2>This is a header</h2>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses h3 headers and paragraphs" do
    test_str = "## This is a header\nAnd a paragraph"
    expected = '<h2>This is a header</h2><p>And a paragraph</p>'
    expect(@translator.to_html(test_str)).to eq expected
  end

end
