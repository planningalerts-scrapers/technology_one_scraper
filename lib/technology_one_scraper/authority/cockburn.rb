require "technology_one_scraper/postback"

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

      # Find the link to the given page number (if it's there)
      def self.find_link_for_page_number(page, i)
        links = page.search("tr.pagerRow").search("td a, td span")
        # Let's find the link with the required page
        texts = links.map { |l| l.inner_text }
        number_texts = texts.select { |t| t != "..." }
        max_page = number_texts.max { |l| l.to_i }.to_i
        min_page = number_texts.min { |l| l.to_i }.to_i
        if i == min_page - 1 && texts[0] == "..."
          links[0]
        elsif i >= min_page && i <= max_page
          links.find {|l| l.inner_text == i.to_s }
        elsif i == max_page + 1 && texts[-1] == "..."
          links[-1]
        end
      end

      def self.extract_current_page_no(page)
        page.search("tr.pagerRow").search("td span").inner_text.to_i
      end

      def self.next_page(page)
        i = extract_current_page_no(page)
        link = find_link_for_page_number(page, i + 1)
        Postback.click(link, page) if link
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
          page = next_page(page)
        end
      end
    end
  end
end
