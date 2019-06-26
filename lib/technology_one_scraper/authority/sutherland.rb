require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Sutherland
      def self.scrape_and_save
        period = 'TM'
        base_url = "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty"
        webguest = "SSC.P1.WEBGUEST"

        params = {
          "Field" => "S",
          "Period" => period,
          "Group" => "DA",
          "SearchFunction" => "SSC.P1.ETR.SEARCH.DA",
          "r" => webguest,
          "f" => "SSC.ETR.SRCH.STW.DA",
          "ResultsFunction" => "SSC.P1.ETR.RESULT.DA"
        }
        url = "#{base_url}/P1/eTrack/eTrackApplicationSearchResults.aspx?#{params.to_query}"

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)

        while page
          Page::Index.scrape(page, webguest) do |record|
            TechnologyOneScraper.save(
              'council_reference' => record[:council_reference],
              'address' => record[:address],
              'description' => record[:description],
              'info_url' => record[:info_url],
              'date_scraped' => Date.today.to_s,
              'date_received' => record[:date_received],
            )
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
