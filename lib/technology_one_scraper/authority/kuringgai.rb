require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Kuringgai
      def self.scrape_page(page, info_url)
        page.at("table.grid").search("tr.normalRow,tr.alternateRow").each do |tr|
          day, month, year = tr.search('td')[1].inner_text.split("/").map{|s| s.to_i}
          record = {
            "info_url" => info_url + tr.search('a')[0].inner_text,
            "council_reference" => tr.search('a')[0].inner_text,
            "date_received" => Date.new(year, month, day).to_s,
            "description" => tr.search('td')[2].inner_text.squeeze(" ").strip,
            "address" => tr.search('a')[1].inner_text,
            "date_scraped" => Date.today.to_s
          }
          TechnologyOneScraper.save(record)
        end
      end

      def self.scrape_and_save
        period = 'L28'

        url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=KC_WEBGUEST&f=P1.ETR.SEARCH.STW"
        info_url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd/P1/eTrack/eTrackApplicationDetails.aspx?r=KC_WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId="

        agent = Mechanize.new
        page = agent.get(url)

        while page
          scrape_page(page, info_url)
          page = Page::Index.next(page)
        end
      end
    end
  end
end
