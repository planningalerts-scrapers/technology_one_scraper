require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Lithgow
      def self.scrape_and_save
        TechnologyOneScraper.scrape_and_save_period(
          "https://eservices.lithgow.nsw.gov.au/ePropertyProd",
          "L14"
        )
      end
    end
  end
end
