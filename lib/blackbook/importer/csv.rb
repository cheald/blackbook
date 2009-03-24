##
# Imports contacts from a CSV file

class Blackbook::Importer::Csv < Blackbook::Importer::Base

  DEFAULT_COLUMNS = [:name,:email,:misc]
  DEFAULT_PATTERN = /,/

  ##
  # Matches this importer to a file that contains CSV values

  def =~(options)
    options && options[:file].respond_to?(:open) ? true : false
  end

  ##
  # fetch_contacts! implementation for this importer

  def fetch_contacts!
    lines   = IO.readlines(options[:file].path)
    columns = to_columns(lines.first)
    lines.shift if columns.first == :name
    columns = DEFAULT_COLUMNS.dup unless columns.first == :name

    contacts = Array.new
    lines.each do |l|
      vals = l.split(pattern)
      next if vals.empty?
      contacts << to_hash(columns, vals)
    end

    contacts
  end

  def to_hash(cols, vals) # :nodoc:
    h = Hash.new
    cols.each do |c|
      h[c] = (c == cols.last) ? vals.join(',') : vals.shift
    end
    h
  end

  def to_columns(line) # :nodoc:
    columns = Array.new
    if line.match(pattern)
      tags = line.split(pattern)
    else
      tags = line.split(DEFAULT_PATTERN)
    end
    # deal with "Name,E-mail..." oddity up front
    if tags.first =~ /^name$/i
      tags.shift
      columns << :name
      if tags.first =~ /^e.?mail/i # E-mail or Email
        tags.shift
        columns << :email
      end
    end
    tags.each{|v| columns << v.strip.to_sym}
    columns
  end
  
  def pattern
    @pattern ||= (options[:pattern] || DEFAULT_PATTERN) rescue DEFAULT_PATTERN
  end

  Blackbook.register(:csv, self)
end
