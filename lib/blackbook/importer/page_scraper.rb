require 'rubygems'
gem 'mechanize', '>= 0.9.2'
require 'mechanize'

##
# A base class for importers that scrape their contacts from web services

class Blackbook::Importer::PageScraper < Blackbook::Importer::Base

  attr_accessor :agent
  
  ##
  # creates the Mechanize agent used to do the scraping and sets a nice
  # user agent header for good net educate 

  def create_agent
    self.agent = WWW::Mechanize.new
    agent.user_agent = "Mozilla/4.0 (compatible; Blackbook #{Blackbook::VERSION})"
    agent.keep_alive = false
    agent
  end
  
  ##
  # Page scrapers will follow a fairly simple pattern of instantiating the 
  # agent, prepping for the scrape and then the actual scrape process

  def fetch_contacts!
    create_agent
    prepare
    scrape_contacts
  end
  
  ##
  # Providers will often require you to login or otherwise prepare to actual 
  # scrape the contacts

  def prepare; end # stub

  ##
  # Some providers have a single page you can scrape from (like Gmail's HTML 
  # Contacts page) while others might require you to navigate several pages, 
  # scraping as you go.

  def scrape_contacts; end # stub
  
  ##
  # helper to strip html from text

  def strip_html( html )
    html.gsub(/<\/?[^>]*>/, '')
  end
end
