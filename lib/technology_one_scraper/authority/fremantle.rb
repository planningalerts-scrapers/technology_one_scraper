require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Fremantle
      def self.scrape_and_save
        url = TechnologyOneScraper.url_period(
          "https://eservices.fremantle.wa.gov.au/ePropertyPROD",
          "L7"
        )

        agent = Mechanize.new
        page = agent.get(url)

        # TODO: Add pagination support
        Page::Index.scrape(page) do |record|
          # TODO: Make the search ignore these rather than filtering them out here
          if record["council_reference"].start_with?("DA", "LL", "VA", "WAPC", "ET", "PW") #selects planning applications only
            TechnologyOneScraper.save(record)
          end
        end
      end
    end
  end
end
