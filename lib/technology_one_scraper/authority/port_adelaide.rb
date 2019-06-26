require 'scraperwiki'
require 'mechanize'
require 'uri'

module TechnologyOneScraper
  module Authority
    module PortAdelaide
      def self.scrape_page2(page)
        page.search("tr[@class='normalRow'], tr[@class='alternateRow']").each do |row|
          cells = row.search('td')

          council_reference = cells[0].search("a").text
          yield(
            council_reference: council_reference,
            address: cells[3].text,
            description: cells[2].text,
            info_url: "https://ecouncil.portenf.sa.gov.au/T1PRWebPROD/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=PAE.P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId=#{URI::escape(council_reference)}",
            date_received: Date.parse(cells[1].text).strftime("%Y-%m-%d")
          )
        end
      end

      def self.scrape_page(page)
        scrape_page2(page) do |record|
          # selects planning applications only
          if record[:council_reference] && record[:council_reference].start_with?("040")
            yield(
              'council_reference' => record[:council_reference],
              'address' => record[:address],
              'description' => record[:description],
              'info_url' => record[:info_url],
              'date_received' => record[:date_received],
              'date_scraped' => Date.today.to_s
            )
          end
        end
      end

      def self.scrape_and_save
        agent = Mechanize.new
        url = "https://ecouncil.portenf.sa.gov.au/T1PRWebPROD/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=L7&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.SL7"
        page = agent.get(url)
        # TODO: Handle pagination
        scrape_page(page) do |record|
          TechnologyOneScraper.save(record)
        end
      end
    end
  end
end
