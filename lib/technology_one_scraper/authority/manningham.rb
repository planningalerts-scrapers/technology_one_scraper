require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Manningham
      def self.scrape_and_save
        url = TechnologyOneScraper.url_period(
          "https://eproclaim.manningham.vic.gov.au/eProperty",
          "TM"
        )

        agent = Mechanize.new
        page = agent.get(url)

        while (page)
          Page::Index.scrape(page) do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
