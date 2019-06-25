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
      #     p record
          puts "Saving record " + record['council_reference'] + ", " + record['address']
          ScraperWiki.save_sqlite(['council_reference'], record)
        end
      end

      # Implement a click on a link that understands stupid asp.net doPostBack
      def self.click(page, doc)
        href = doc["href"]
        if href =~ /javascript:__doPostBack\(\'(.*)\',\'(.*)'\)/
          event_target = $1
          event_argument = $2
          form = page.form_with(id: "aspnetForm")
          form["__EVENTTARGET"] = event_target
          form["__EVENTARGUMENT"] = event_argument
          form.submit
        else
          # TODO Just follow the link likes it's a normal link
          raise
        end
      end

      def self.scrape_and_save
        period = 'TW'

        url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=" + period + "&r=KC_WEBGUEST&f=P1.ETR.SEARCH.STW"
        info_url = "https://eservices.kmc.nsw.gov.au/T1ePropertyProd/P1/eTrack/eTrackApplicationDetails.aspx?r=KC_WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId="

        agent = Mechanize.new

        page = agent.get(url)
        current_page_no = 1
        next_page_link = true

        while next_page_link
          puts "Scraping page #{current_page_no}..."
          scrape_page(page, info_url)

          page_links = page.at(".pagerRow")
          if page_links
            next_page_link = page_links.search("a").find{|a| a.inner_text == (current_page_no + 1).to_s}
          else
            next_page_link = nil
          end
          if next_page_link
            current_page_no += 1
            page = click(page, next_page_link)
          end
        end
      end
    end
  end
end
