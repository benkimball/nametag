require 'thor'

class Nametag < Thor
  option :from, :required => true, :banner => 'FROM_RECIPIENT_ID', :type => :numeric
  option :to,   :required => true, :banner => 'TO_RECIPIENT_ID', :type => :numeric
  desc "reassign FILE", "Reassign tabs from one recipient ID to another"
  long_desc <<-LONGDESC
    Finds all tabs assigned to a recipient and changes their recipient ID
    Example: nametag reassign infile.xml --from 8 --to 2
  LONGDESC
  def reassign(infile)
    from = options[:from]
    to = options[:to]
    error("Could not find file #{infile}") unless File.exists?(infile)

    tmpl = Template.new(infile)
    [from, to].each do |id|
      error("Unknown recipient #{id}") unless tmpl.valid_recipient_id?(id)
    end

    tmpl.reassign_recipients!(from, to)
    $stdout.print tmpl.to_xml
  end

  desc "xpath FILE SELECTOR", "Search template with xpath selector"
  def xpath(infile, selector)
    error("Could not find file #{infile}") unless File.exists?(infile)
    tmpl = Template.new(infile)
    puts tmpl.xpath(selector)
  end

  private
  def error(str)
    puts [nil, "Error: #{str}"]
    exit 1
  end
end
