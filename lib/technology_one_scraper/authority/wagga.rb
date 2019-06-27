require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Wagga
      def self.scrape_page(page, info_url_base)
        page.at("table.grid").search("tr.normalRow, tr.alternateRow").each do |tr|
          tds = tr.search("td")
          day, month, year = tds[1].inner_text.split("/").map{|s| s.to_i}
          council_reference = tds[0].inner_text

          yield(
            council_reference: council_reference,
            date_received: Date.new(year, month, day).to_s,
            description: tds[2].inner_text,
            address: tds[5].inner_text,
            info_url: info_url_base + CGI.escape(council_reference)
          )
        end
      end

      def self.scrape_and_save
        base_url = "https://eservices.wagga.nsw.gov.au/T1PRWeb/eProperty/P1/eTrack"
        url = "#{base_url}/eTrackApplicationSearchResults.aspx?Field=S&Period=L14&r=WW.P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL14"
        info_url_base = "#{base_url}/eTrackApplicationDetails.aspx?r=WW.P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId="

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)
        current_page_no = 1

        while page
          scrape_page(page, info_url_base) do |record|
            TechnologyOneScraper.save(
              "council_reference" => record[:council_reference],
              "date_received" => record[:date_received],
              "description" => record[:description],
              "address" => record[:address],
              "date_scraped" => Date.today.to_s,
              "info_url" => record[:info_url]
            )
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
