require 'kconv'
require 'blackbook/importer/page_scraper'

if RUBY_VERSION > "1.9"    
 require "csv"  
 unless defined? FCSV
   class Object  
     FCSV = CSV 
     alias_method :FCSV, :CSV
   end  
 end
else
 require "fastercsv"
end

##
# Imports contacts from GMail

class Blackbook::Importer::Gmail < Blackbook::Importer::PageScraper

  RETRY_THRESHOLD = 5
  ##
  # Matches this importer to an user's name/address
  
  def =~(options = {})
    options && options[:username] =~ /@(gmail|googlemail).com$/i ? true : false
  end
  
  ##
  # login to gmail

  def login
    page = agent.get('http://mail.google.com/mail/')
    form = page.forms.first
    form.Email = options[:username]
    form.Passwd = options[:password]
    page = agent.submit(form,form.buttons.first)
    
    raise( Blackbook::BadCredentialsError, "That username and password was not accepted. Please check them and try again." ) if page.body =~ /Username and password do not match/
    
    if page.search('//meta').first.attributes['content'] =~ /url='?(http.+?)'?$/i
      page = agent.get $1
    end
  end
  
  ##
  # prepare this importer

  def prepare
    login
  end
  
  ##
  # scrape gmail contacts for this importer

  def scrape_contacts
    unless agent.cookies.find{|c| c.name == 'GAUSR' && 
                           (c.value.include? "mail:#{options[:username]}")}
      raise( Blackbook::BadCredentialsError, "Must be authenticated to access contacts." )
    end

	contacts = []
    csv = agent.get('https://mail.google.com/mail/contacts/data/export?exportType=ALL&out=GMAIL_CSV')
	body = Kconv.toutf8(csv.body)
	FCSV.parse(body) do |row|
		next if row[0] == "Name" and row[1] == "E-mail"
		contacts << {:name => row[0], :email => row[1]} unless row[1].blank?
	end
	return contacts
  end
  
  Blackbook.register(:gmail, self)
end
