require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Cockburn
      def self.scrape_and_save
        TechnologyOneScraper.scrape_and_save_period(
          "https://ecouncil.cockburn.wa.gov.au/eProperty",
          "TM"
        )
      end
    end
  end
end
