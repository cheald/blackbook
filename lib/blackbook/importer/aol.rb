require 'blackbook/importer/page_scraper'

##
# Imports contacts from AOL

class Blackbook::Importer::Aol < Blackbook::Importer::PageScraper

  ##
  # Matches this importer to an user's name/address

  def =~( options )
    options && options[:username] =~ /@(aol|aim)\.com$/i ? true : false
  end
  
  ##
  # Login process:
  # - Get mail.aol.com which redirects to a page containing a javascript redirect
  # - Get the URL that the javascript is supposed to redirect you to
  # - Fill out and submit the login form
  # - Get the URL from *another* javascript redirect

  def login
    page = agent.get( 'http://webmail.aol.com/' )

    form = page.forms.find{|form| form.name == 'AOLLoginForm'}
    form.loginId = options[:username].split('@').first # Drop the domain
    form.password = options[:password]
    page = agent.submit(form, form.buttons.first)

    case page.body
    when /Invalid Screen Name or Password. Please try again./
      raise( Blackbook::BadCredentialsError, "That username and password was not accepted. Please check them and try again." )
    when /Terms of Service/
      raise( Blackbook::LegacyAccount, "Your AOL account is not setup for WebMail. Please signup: http://webmail.aol.com")
    end

    base_uri = page.body.scan(/^var gSuccessPath = \"(.+)\";/).first.first
    raise( Blackbook::BadCredentialsError, "You do not appear to be signed in." ) unless base_uri
    page = agent.get base_uri
  end
  
  ##
  # must login to prepare

  def prepare
    login
  end
  
  ##
  # The url to scrape contacts from has to be put together from the Auth cookie
  # and a known uri that hosts their contact service. An array of hashes with
  # :name and :email keys is returned.

  def scrape_contacts    
    unless auth_cookie = agent.cookies.find{|c| c.name =~ /^Auth/}
      raise( Blackbook::BadCredentialsError, "Must be authenticated to access contacts." )
    end
    
    # jump through the hoops of formulating a request to get printable contacts
    uri = agent.current_page.uri.dup
    inputs = agent.current_page.search("//input")
    user = inputs.detect{|i| i['type'] == 'hidden' && i['name'] == 'user'}
    utoken = user['value']

    path = uri.path.split('/')
    path.pop
    path << 'addresslist-print.aspx'
    uri.path = path.join('/')
    uri.query = "command=all&sort=FirstLastNick&sortDir=Ascending&nameFormat=FirstLastNick&user=#{utoken}"
    page = agent.get uri.to_s

    # Grab all the contacts
    rows = page.search("table tr")
    name, email = nil, nil
    
    results = []
    rows.each do |row|
      new_name = row.search("span[@class='fullName']").inner_text.strip
      if name.blank? || !new_name.blank?
        name = new_name
      end
      next if name.blank?
    
      email = row.search("td[@class='sectionContent'] span:last").inner_text.strip
      next if email.blank?
    
      results << {:name => name, :email => email}
      name, email = nil, nil
    end
    results
  end
  
  Blackbook.register :aol, self
end
