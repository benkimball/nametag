require 'nokogiri'

class Template

  class Recipient
    attr_reader :id, :role_name, :routing_order, :type, :email
    def initialize(element)
      @id            = element.at_css("ID").content.to_i
      @role_name     = element.at_css("RoleName").content
      @routing_order = element.at_css("RoutingOrder").content.to_i
      @type          = element.at_css("Type").content
      @email         = element.at_css("Email").content
    end
    def to_s
      "%-8d%-8d%-16s%-16s%s" % [id, routing_order, role_name, type, email]
    end
  end

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
    @recipients ||= @doc.css("Recipients Recipient").map { |e| Recipient.new(e) }
  end

  def valid_recipient_id?(id)
    recipients.map(&:id).include? id
  end

  def delete_recipient!(id)
    xpath = "//" + element("Recipients")
    xpath += "/" + element("Recipient")
    xpath += "[" + element("ID") + "=#{id}]"
    tab = @doc.at_xpath(xpath)
    if tab
      tab.remove
    end
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
