require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Tamworth
      def self.scrape_page(page, info_url_base)
        page.at("table.grid").search("tr.normalRow, tr.alternateRow").each do |tr|
          tds = tr.search("td")
          day, month, year = tds[3].inner_text.split("/").map{|s| s.to_i}

          council_reference = tds[0].inner_text
          record = {
            "council_reference" => council_reference,
            "date_received" => Date.new(year, month, day).to_s,
            "address" => tds[1].inner_text,
            "description" => tds[6].inner_text,
            "date_scraped" => Date.today.to_s,
            "info_url" => info_url_base + CGI.escape(council_reference)
          }

          # The description of community facilities development can be unhelpful,
          # like just "other", so provide a little helpful context.
          if tds[5].text == "Community Facilities Development"
            record["description"].prepend("Community Facilities Development: ")
          end

          yield record
        end
      end

      def self.scrape_and_save
        period = 'TM'

        base_url = "https://eproperty.tamworth.nsw.gov.au/ePropertyProd/P1/eTrack"
        url = "#{base_url}/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL14"
        info_url_base = "#{base_url}/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId="

        agent = Mechanize.new

        # Read in a page
        page = agent.get(url)

        while page
          scrape_page(page, info_url_base) do |record|
            TechnologyOneScraper.save(record)
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
