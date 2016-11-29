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
    from = options[:from].to_i
    to = options[:to].to_i
    with_template(infile) do |tmpl|
      error("Unknown recipient #{from}") unless tmpl.valid_recipient_id?(from)
      error("Unknown recipient #{to}") unless tmpl.valid_recipient_id?(to)
      tmpl.reassign_recipients!(from, to)
      $stdout.print tmpl.to_xml
    end
  end

  desc "delete FILE RECIPIENT_ID", "Remove a recipient without changing tabs"
  def delete(infile, recipient_id)
    id = recipient_id.to_i
    with_template(infile) do |tmpl|
      error("Unknown recipient #{id}") unless tmpl.valid_recipient_id?(id)
      tmpl.delete_recipient!(id)
      $stdout.print tmpl.to_xml
    end
  end

  desc "rename FILE RECIPIENT_ID NEW_ROLE_NAME", "Rename a recipient's role"
  def rename(infile, recipient_id, new_role_name)
    id = recipient_id.to_i
    with_template(infile) do |tmpl|
      error("Unknown recipient #{id}") unless tmpl.valid_recipient_id?(id)
      recipient = tmpl.recipient(id)
      recipient.role_name = new_role_name if recipient
      $stdout.print tmpl.to_xml
    end
  end

  desc "list FILE", "List all recipients in the template"
  def list(infile)
    with_template(infile) do |tmpl|
      puts "ID      Order   RoleName        Type"
      puts tmpl.recipients.sort_by(&:routing_order)
    end
  end

  desc "xpath FILE SELECTOR", "Search template with xpath selector"
  def xpath(infile, selector)
    with_template(infile) do |tmpl|
      puts tmpl.xpath(selector)
    end
  end

  private
  def error(str)
    puts [nil, "Error: #{str}"]
    exit 1
  end

  def with_template(infile)
    error("Could not find file #{infile}") unless File.exists?(infile)
    yield Template.new(infile)
  end
end
