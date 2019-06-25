require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Kuringgai
      def self.scrape_and_save
        period = 'L28'

        url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=KC_WEBGUEST&f=P1.ETR.SEARCH.STW"

        agent = Mechanize.new
        page = agent.get(url)

        while page
          Page::Index.scrape(page, "KC_WEBGUEST") do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
