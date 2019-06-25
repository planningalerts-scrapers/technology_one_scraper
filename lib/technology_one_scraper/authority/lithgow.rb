require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Lithgow
      def self.scrape_page(page, info_url_base)
        page.search("table.grid tr.normalRow, table.grid tr.alternateRow").each do |tr|

          record = {
            'council_reference' => tr.search("td")[0].inner_text,
            'address' => tr.search("td")[5].inner_text.gsub('  ', ', '),
            'description' => tr.search("td")[2].inner_text,
            'info_url' => info_url_base + tr.search("td")[0].inner_text,
            'date_scraped' => Date.today.to_s,
            'date_received' => Date.parse(tr.search("td")[1].inner_text).to_s,
          }

          TechnologyOneScraper.save(record)
        end
      end

      def self.scrape_and_save
        period = 'L14'

        base_url = "https://eservices.lithgow.nsw.gov.au/ePropertyProd/P1/eTrack"
        url = "#{base_url}/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.S" + period
        info_url_base = "#{base_url}/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId="

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)

        while page
          scrape_page(page, info_url_base)
          page = Page::Index.next(page)
        end
      end
    end
  end
end
