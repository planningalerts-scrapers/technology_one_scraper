require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Sutherland
      def self.scrape_and_save
        period = 'TM'
        base_url = "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty"
        webguest = "SSC.P1.WEBGUEST"

        url = "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=TM&r=SSC.P1.WEBGUEST&f=%24P1.ETR.SEARCH.STM"

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
