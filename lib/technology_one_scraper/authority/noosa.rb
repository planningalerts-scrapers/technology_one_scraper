require 'scraperwiki'
require 'mechanize'
require 'uri'

module TechnologyOneScraper
  module Authority
    module Noosa
      def self.scrape_and_save
        period = "TM"

        url = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=$P1.ETR.SEARCH.S' + period

        agent = Mechanize.new
        agent_detail_page = Mechanize.new
        page = agent.get(url)

        while page
          Page::Index.scrape(page) do |record|
            if record[:council_reference].nil? ||
               record[:address].nil? ||
               record[:description].nil? ||
               record[:date_received].nil?
              # We need more information. We can get this from the detail page
              detail_page = agent_detail_page.get(record[:info_url])
              record_detail = Page::Detail.scrape(detail_page)
              record = record.merge(record_detail)
              # TODO: Check that we have enough now
            end

            TechnologyOneScraper.save(
              'council_reference' => record[:council_reference],
              'address' => record[:address],
              'description' => record[:description],
              'info_url' => record[:info_url],
              'date_scraped' => Date.today.to_s,
              'date_received' => record[:date_received]
            )
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
