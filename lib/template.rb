require 'nokogiri'

class Template
  DS_NAMESPACE = 'xmlns'

  def initialize(filename)
    @doc = Nokogiri::XML(File.open(filename)) do |config|
      config.strict.nonet
    end
  end

  def xpath(selector)
    @doc.xpath(selector).inspect
  end

  def to_xml
    @doc.to_xml
  end

  def recipients
    @recipients ||= begin
      @doc.css("Recipients Recipient").map do |recipient|
        id = recipient.at_css("ID").content.to_i
        role_name = recipient.at_css("RoleName").content
        [id, role_name]
      end
    end
  end

  def valid_recipient_id?(id)
    recipients.map(&:first).include? id
  end

  def reassign_recipients!(from, to)
    xpath = "//" + element("Tabs")
    xpath += "/" + element("Tab")
    xpath += "[" + element("RecipientID") + "=#{from}]"
    xpath += "/" + element("RecipientID")
    tabs = @doc.xpath(xpath)
    if tabs
      tabs.each do |tab|
        tab.content = to
      end
    end
  end

  private
  def element(s)
    [DS_NAMESPACE, s].join(':')
  end

end
