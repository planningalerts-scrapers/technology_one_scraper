require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Kuringgai
      def self.scrape_page(page)
        table = page.at("table.grid")
        Table.extract_table(table).each do |row|
          council_reference = row["Application Link"]
          info_url = "eTrackApplicationDetails.aspx" +
                     "?ApplicationId=" + council_reference +
                     "&f=$P1.ETR.APPDET.VIW" +
                     "&r=KC_WEBGUEST"
          record = {
            "info_url" => (page.uri + info_url).to_s,
            "council_reference" => council_reference,
            "date_received" => Date.strptime(row["Lodgement Date"], "%d/%m/%Y").to_s,
            "description" => row["Description"].squeeze(" "),
            "address" => row["Formatted Address"],
            "date_scraped" => Date.today.to_s
          }
          TechnologyOneScraper.save(record)
        end
      end

      def self.scrape_and_save
        period = 'L28'

        url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=KC_WEBGUEST&f=P1.ETR.SEARCH.STW"

        agent = Mechanize.new
        page = agent.get(url)

        while page
          scrape_page(page)
          page = Page::Index.next(page)
        end
      end
    end
  end
end
