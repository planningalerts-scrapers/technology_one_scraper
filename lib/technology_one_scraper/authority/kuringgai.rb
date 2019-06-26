require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Kuringgai
      def self.scrape_and_save
        TechnologyOneScraper.scrape_and_save_period(
          "https://eservices.kmc.nsw.gov.au/T1ePropertyProd",
          'TM',
          "KC_WEBGUEST"
        )
      end
    end
  end
end
