require 'scraperwiki'
require 'mechanize'
require 'uri'

module TechnologyOneScraper
  module Authority
    module PortAdelaide
      def self.scrape_and_save
        webguest = "PAE.P1.WEBGUEST"

        # Hmmm. not a consistent webguest.
        url = TechnologyOneScraper.url_period(
          "https://ecouncil.portenf.sa.gov.au/T1PRWebPROD/eProperty",
          "L7"
        )

        agent = Mechanize.new
        page = agent.get(url)

        while page
          Page::Index.scrape(page, webguest) do |record|
            # selects planning applications only
            if record[:council_reference] && record[:council_reference].start_with?("040")
              TechnologyOneScraper.save(
                'council_reference' => record[:council_reference],
                'address' => record[:address],
                'description' => record[:description],
                'info_url' => record[:info_url],
                'date_received' => record[:date_received],
                'date_scraped' => Date.today.to_s
              )
            end
          end
          page = Page::Index.next(page)
        end
      end
    end
  end
end
