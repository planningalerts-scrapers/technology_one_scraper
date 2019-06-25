require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Kuringgai
      def self.scrape_and_save
        webguest = "KC_WEBGUEST"

        url = TechnologyOneScraper.url_period(
          "https://eservices.kmc.nsw.gov.au/T1ePropertyProd",
          'TM',
          webguest
        )

        agent = Mechanize.new
        page = agent.get(url)

        while page
          Page::Index.scrape(page, webguest) do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
