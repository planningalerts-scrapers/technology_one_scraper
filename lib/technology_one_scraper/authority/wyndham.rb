require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Wyndham
      def self.scrape_and_save_index_page(page, url)
        table_rows = page.search("table#ctl00_Content_cusResultsGrid_repWebGrid_ctl00_grdWebGridTabularView").search('tr')
        table_tr_number = table_rows.length
        table_rows.each_with_index do |tr, index|

          #The tables come with a header tr[0] and two tr at bottom tr[21], tr[22]. This function wants to access the table data only, so we skip these header and footer rows
          if index == 0 or index == table_tr_number-1 or index == table_tr_number-2
            next
          end

          council_reference = tr.search("td")[0].inner_text
          link_to_decision = "https://eproperty.wyndham.vic.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId=#{council_reference}"

          date_received_unformatted = tr.search("td")[1].inner_text
          day, month, year = date_received_unformatted.split("/")
          date_received_formatted = "#{year}-#{month}-#{day}"

          yield(
            info_url: link_to_decision,
            council_reference: council_reference,
            date_received: date_received_formatted,
            description: tr.search("td")[2].inner_text,
            address: tr.search("td")[3].inner_text,
            status: tr.search("td")[4].inner_text,
            decision: tr.search("td")[5].inner_text
          )
        end
      end

      def self.scrape_and_save
        url = "https://eproperty.wyndham.vic.gov.au/ePropertyPROD/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=L28&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL28"
        agent = Mechanize.new

        page = agent.get(url)

        while page
          scrape_and_save_index_page(page, url) do |record|
            TechnologyOneScraper.save(
              "info_url" => record[:info_url],
              "council_reference" => record[:council_reference],
              "date_received" => record[:date_received],
              "description" => record[:description],
              "address" => record[:address],
              # TODO: Remove status and decision
              "status" => record[:status],
              "decision" => record[:decision],
              "date_scraped" => Date.today.to_s
            )
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
