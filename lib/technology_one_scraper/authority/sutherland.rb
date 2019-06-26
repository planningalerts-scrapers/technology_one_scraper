require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Sutherland
      def self.scrape_and_save
        webguest = "SSC.P1.WEBGUEST"

        url = TechnologyOneScraper.url_period(
          "https://propertydevelopment.ssc.nsw.gov.au/T1PRPROD/WebApps/eproperty",
          "TM",
          webguest
        )

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
