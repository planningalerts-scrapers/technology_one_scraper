require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Cockburn
      def self.scrape_and_save
        period = "TM"
        url = 'https://ecouncil.cockburn.wa.gov.au/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.S' + period

        agent = Mechanize.new
        page = agent.get(url)

        while page
          Page::Index.scrape(page) do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
