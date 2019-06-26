require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Tamworth
      def self.scrape_and_save
        period = 'TM'

        base_url = "https://eproperty.tamworth.nsw.gov.au/ePropertyProd/P1/eTrack"
        url = "#{base_url}/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL14"

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)

        while page
          Page::Index.scrape(page) do |record|
            TechnologyOneScraper.save(
              "council_reference" => record[:council_reference],
              "date_received" => record[:date_received],
              "address" => record[:address],
              "description" => record[:description],
              "date_scraped" => Date.today.to_s,
              "info_url" => record[:info_url]
            )
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
