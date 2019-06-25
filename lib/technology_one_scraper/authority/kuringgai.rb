require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Kuringgai
      def self.scrape_and_save
        period = 'TM'
        webguest = "KC_WEBGUEST"
        base_url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd"

        params = {
          "Field" => "S",
          "Period" => period,
          "r" => webguest,
          "f" => "$P1.ETR.SEARCH.S#{period}"
        }
        url = "#{base_url}/P1/eTrack/eTrackApplicationSearchResults.aspx?#{params.to_query}"

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
