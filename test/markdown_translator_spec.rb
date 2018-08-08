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

  it "parses h1 headers" do
    test_str = '# This is a header'
    expected = '<h1>This is a header</h1>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses h2 headers" do
    test_str = '## This is a header'
    expected = '<h2>This is a header</h2>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses h3 headers and paragraphs" do
    test_str = "### This is a header\nAnd a paragraph"
    expected = '<h3>This is a header</h3><p>And a paragraph</p>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses h4 headers and paragraphs" do
    test_str = "\n\n#### This is a header\nAnd a paragraph.\nAnd another line."
    expected = '<h4>This is a header</h4><p>And a paragraph. And another line.</p>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses chunks together" do
    test_str = "#### This is a header\nAnd a paragraph.\n\nAnd another paragraph.\n\n# Header 1"
    expected = '<h4>This is a header</h4><p>And a paragraph.</p><p>And another paragraph.</p><h1>Header 1</h1>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses chunks of headers and paragraphs" do
    test_str = "Paragraph text\n# Header 1\nParagraph 2\n## Header 2"
    expected = '<p>Paragraph text</p><h1>Header 1</h1><p>Paragraph 2</p><h2>Header 2</h2>'
    expect(@translator.to_html(test_str)).to eq expected
  end

end
