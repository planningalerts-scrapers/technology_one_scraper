require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Cockburn
      def self.scrape_index_page(page)
        results = page.search("tr.normalRow, tr.alternateRow")

        results.each do |result|
          council_reference = result.search("td")[0].inner_text
          info_url = 'eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId=' +
                     # TODO: Do proper escaping rather than this hack
                     council_reference.gsub("/", "%2f")

          yield(
            'council_reference' => council_reference,
            'address'           => result.search("td")[3].inner_text.to_s,
            'description'       => result.search("td")[2].inner_text.to_s,
            'info_url'          => (page.uri + info_url).to_s,
            'date_scraped'      => Date.today.to_s,
            'date_received'     => Date.parse(result.search("td")[1]).to_s
          )
        end
      end

      def self.scrape_and_save
        period = "TM"
        url = 'https://ecouncil.cockburn.wa.gov.au/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.S' + period

        agent = Mechanize.new
        page = agent.get(url)

        while page
          scrape_index_page(page) do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
