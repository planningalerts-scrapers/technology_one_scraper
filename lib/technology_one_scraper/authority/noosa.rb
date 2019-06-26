require 'scraperwiki'
require 'mechanize'
require 'uri'

module TechnologyOneScraper
  module Authority
    module Noosa
      def self.scrape_and_save
        period = "TM"

        url         = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=$P1.ETR.SEARCH.S' + period
        info_url    = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId='

        agent = Mechanize.new
        agent_detail_page = Mechanize.new
        page = agent.get(url)

        while page
          Page::Index.scrape2(page) do |record_index|
            detail_page = agent_detail_page.get(record_index[:info_url])
            record_detail = Page::Detail.scrape(detail_page)
            record = {
              'council_reference' => record_index[:council_reference],
              'address' => record_detail[:address],
              'description' => record_detail[:description],
              'info_url' => record_index[:info_url],
              'date_scraped' => Date.today.to_s,
              'date_received' => record_index[:date_received]
            }
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
