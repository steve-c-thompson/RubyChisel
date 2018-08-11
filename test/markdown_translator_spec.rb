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

  it "parses ul lists" do
    test_str = "Paragraph text\n\n* Item 1\n* Item 2"
    expected = '<p>Paragraph text</p><ul><li>Item 1</li><li>Item 2</li></ul>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses ul lists with headers" do
    test_str = "## Header\n* Item 1\n* Item 2"
    expected = '<h2>Header</h2><ul><li>Item 1</li><li>Item 2</li></ul>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline **text** to  <strong>text</strong>" do
    test_str = "**text**"
    expected = "<p><strong>text</strong></p>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline **** to  <strong></strong>" do
    test_str = "****"
    expected = "<p><strong></strong></p>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline ** ** in other text to <strong></strong>" do
    test_str = "words **strong** more"
    expected = "<p>words <strong>strong</strong> more</p>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline header ** ** in other text to <strong></strong>" do
    test_str = "# **strong** more"
    expected = "<h1><strong>strong</strong> more</h1>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline * * in other text to <em> some text </em>" do
    test_str = "words * some text * more"
    expected = "<p>words <em> some text </em> more</p>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline header * * in other text to <em></em>" do
    test_str = "# *emphasis* more"
    expected = "<h1><em>emphasis</em> more</h1>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes mixed ** and * to em and strong" do
    test_str = "**strong and *emphasized text* strings**"
    expected = "<p><strong>strong and <em>emphasized text</em> strings</strong></p>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline bullet * * with ** ** in other text strong and em" do
    test_str = "* *EM **STRONG** text*"
    test_str <<"\n* more text"
    expected = "<ul><li><em>EM <strong>STRONG</strong> text</em></li>"
    expected << "<li>more text</li></ul>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes inline bullet * * with ** ** in other text strong and em" do
    test_str = "* *EM **STRONG** text* **more strong**"
    test_str <<"\n* more text"
    expected = "<ul><li><em>EM <strong>STRONG</strong> text</em> <strong>more strong</strong></li>"
    expected << "<li>more text</li></ul>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "changes ul lists with inline text" do
    test_str = "* **Item 1**\n* Item 2\n* ***Item 3***"
    expected = '<ul><li><strong>Item 1</strong></li><li>Item 2</li><li><strong><em>Item 3</em></strong></li></ul>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "can strong and em text when markdown together" do
    test_str = "***strong em***"
    expected = "<p><strong><em>strong em</em></strong></p>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "can strong em strong text" do
    test_str = "**strong** *em*\n**strong again**"
    expected = "<p><strong>strong</strong> <em>em</em></p><p><strong>strong again</strong></p>"
  end

  it "parses ol lists with 1." do
    test_str = "Paragraph text\n\n1. Item 1\n1. Item 2"
    expected = '<p>Paragraph text</p><ol><li>Item 1</li><li>Item 2</li></ol>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses ol lists with headers and 1. 2." do
    test_str = "## Header\n1. Item 1\n2. Item 2"
    expected = '<h2>Header</h2><ol><li>Item 1</li><li>Item 2</li></ol>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses ol lists with headers and arbitrary numbres" do
    test_str = "## Header\n11. Item 1\n22. Item 2\n0. Item 3"
    expected = '<h2>Header</h2><ol><li>Item 1</li><li>Item 2</li><li>Item 3</li></ol>'
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses ol line with inline strong em" do
    test_str = '0. ***Item 3***'
    expected = "<ol><li><strong><em>Item 3</em></strong></li></ol>"
    expect(@translator.to_html(test_str)).to eq expected
  end

  it "parses ol lists with inline text" do
    test_str = "11. **Item 1**\n22. Item 2\n0. ***Item 3***"
    expected = '<ol><li><strong>Item 1</strong></li><li>Item 2</li><li><strong><em>Item 3</em></strong></li></ol>'
    expect(@translator.to_html(test_str)).to eq expected
  end
end
