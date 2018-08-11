require_relative 'markdown_translator'

class MarkdownFileParser
  def initialize
    @markdown_trans = MarkdownTranslator.new
  end

  def parse_and_write_file(in_file, out_file)
    f = File.open(in_file, "r")
    content = f.read

    html = @markdown_trans.to_html(content)

    out = File.open(out_file, "w")
    out.write(html)
    out.close
  end
end


mfp = MarkdownFileParser.new

i = ARGV[0]
o = ARGV[1]

mfp.parse_and_write_file(i, o)
