require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Lithgow
      def self.scrape_and_save
        url = TechnologyOneScraper.url_period(
          "https://eservices.lithgow.nsw.gov.au/ePropertyProd",
          "L14"
        )

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)

        while page
          Page::Index.scrape(page) do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
