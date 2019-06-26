require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Ryde
      def self.scrape_index_page(page, info_url)
        results = page.search("tr.normalRow, tr.alternateRow")
        results.each do |result|
          yield(
            council_reference: result.search("td")[0].inner_text.to_s,
            address: result.search("td")[1].inner_text.to_s,
            description: result.search("td")[3].inner_text.to_s,
            info_url: info_url + result.search("td")[0].inner_text.sub!("/", "%2f"),
            date_received: Date.parse(result.search("td")[2]).to_s
          )
        end
      end

      def self.scrape_and_save
        period = "TM"

        url         = 'https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=COR.P1.WEBGUEST&f=$P1.ETR.SEARCH.S' + period
        info_url    = 'https://eservices.ryde.nsw.gov.au/T1PRProd/WebApps/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=COR.P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId='

        agent = Mechanize.new
        page = agent.get(url)

        while page
          scrape_index_page(page, info_url) do |record|
            TechnologyOneScraper.save(
              'council_reference' => record[:council_reference],
              'address'           => record[:address],
              'description'       => record[:description],
              'info_url'          => record[:info_url],
              'date_scraped'      => Date.today.to_s,
              'date_received'     => record[:date_received]
            )
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
