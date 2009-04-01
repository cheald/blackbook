$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))
require 'singleton'
require 'rubygems'

class Blackbook
  include ::Singleton
  VERSION = '1.0.5'
  
  class BlackbookError < ::StandardError; end
  class BadCredentialsError < BlackbookError; end
  class LegacyAccount < BlackbookError; end
  
  attr_accessor :importers
  attr_accessor :exporters
  
  def self.get( *args )
    instance.get( *args )
  end

  def self.register(name, adapter_class)
    case adapter = adapter_class.new
      when Importer::Base
        instance.importers[name.to_sym] = adapter
      when Exporter::Base
        instance.exporters[name.to_sym] = adapter
      else
        raise ArgumentError, "Unknown adapter"
    end
  end
  
  # Sends the vcards from the import to whatever is handling the export
  def export( importer, exporter, options )
    exporter.export importer.import( options )
  end
  
  # Searches registered importers for one that will handle the given options
  def find_importer( options )
    importers.each{ |key, importer| return importer if importer =~ options }
    nil
  end
  
  # Fetches contacts from various services or filetypes. The default is to return an array
  # of hashes - Blackbook's internal format
  # 
  # Handles several different calls:
  #  get( :username => 'something@gmail.com', :password => 'whatever' )
  #  get( :as => :xml, :username => 'something@gmail.com', :password => 'whatever' )
  #  get( :csv, :file => #<File:/path/to/file.csv> )
  def get( *args )
    options   = args.last.is_a?(Hash) ? args.pop : {}
    to_format = exporters[ options[:as] || :basic ]
    source    = (importers[args.first.to_sym] rescue nil) || find_importer(options)

    raise ArgumentError, "Unknown exporter" unless to_format
    raise ArgumentError, "Unknown source" unless source
    
    export source, to_format, options
  end
  
  def initialize
    self.importers = {}
    self.exporters = {}
  end
end

# Require all the importers/exporters
require 'blackbook/importer/base'
require 'blackbook/exporter/base'
Dir.glob(File.join(File.dirname(__FILE__), 'blackbook/importer/*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'blackbook/exporter/*.rb')).each {|f| require f }

class NilClass
  def empty?
    true
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end  
end

