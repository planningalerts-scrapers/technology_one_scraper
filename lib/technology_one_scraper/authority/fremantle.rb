require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Fremantle
      def self.scrape_and_save
        agent = Mechanize.new
        url = "https://eservices.fremantle.wa.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=L7&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL7"
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
