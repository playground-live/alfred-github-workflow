class Item < Struct.new(:uid, :arg, :title, :subtitle, :valid, :icon); end

# alfred output
class XmlBuilder
  attr_reader :output

  def initialize
    @output = "<?xml version='1.0'?>\n"
  end

  def self.build(&_block)
    builder = new
    yield(builder)
    builder.output
  end

  def items(&_block)
    @output << "<items>\n"
    yield(self)
    @output << '</items>'
  end

  def item(item)
    @output << <<-XML
      <item uid="#{item.uid}" arg="#{item.arg}" valid="#{item.valid}">
        <title>#{item.title.encode(xml: :text)}</title>
        <subtitle>#{item.subtitle.encode(xml: :text)}</subtitle>
        <icon>#{item.icon}</icon>
      </item>
    XML
  end

  def hash
    @uid
  end
end
