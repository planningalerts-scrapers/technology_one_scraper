require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Blacktown
      def self.scrape_and_save
        TechnologyOneScraper.scrape_and_save_period(
          "https://eservices.blacktown.nsw.gov.au/T1PRProd/WebApps/eProperty",
          "L28",
          "BCC.P1.WEBGUEST"
        )
      end
    end
  end
end
