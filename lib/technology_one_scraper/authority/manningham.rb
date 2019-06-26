require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Manningham
      def self.scrape_and_save
        TechnologyOneScraper.scrape_and_save_period(
          "https://eproclaim.manningham.vic.gov.au/eProperty",
          "TM"
        )
      end
    end
  end
end
