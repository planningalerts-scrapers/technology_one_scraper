require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Fremantle
      def self.scrape_and_save
        agent = Mechanize.new
        period = "L7"
        base_url = "https://eservices.fremantle.wa.gov.au/ePropertyPROD"
        url = "#{base_url}/P1/eTrack/eTrackApplicationSearchResults.aspx" \
              "?Field=S" \
              "&Period=#{period}" \
              "&r=P1.WEBGUEST" \
              "&f=%24P1.ETR.SEARCH.S#{period}"
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
