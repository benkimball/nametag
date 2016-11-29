require 'nokogiri'

class Template

  DS_NAMESPACE = 'xmlns'

  class Recipient
    attr_reader :id, :role_name, :routing_order, :type, :email
    def initialize(element)
      @root          = element
      @id            = @root.at_css("ID")
      @role_name     = @root.at_css("RoleName")
      @routing_order = @root.at_css("RoutingOrder")
      @type          = @root.at_css("Type")
      @email         = @root.at_css("Email")
    end

    def id; @id.content.to_i; end
    def role_name; @role_name.content; end
    def routing_order; @routing_order.content.to_i; end
    def type; @type.content; end
    def email; @email.content; end

    def role_name=(new_name)
      @role_name.content = new_name
    end

    def to_s
      "%-8d%-8d%-16s%-16s%s" % [id, routing_order, role_name, type, email]
    end
  end

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

  def recipient(id)
    @recipients.detect {|r| r.id == id}
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
