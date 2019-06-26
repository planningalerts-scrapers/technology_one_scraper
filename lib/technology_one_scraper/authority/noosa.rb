require 'scraperwiki'
require 'mechanize'
require 'uri'

module TechnologyOneScraper
  module Authority
    module Noosa
      def self.has_blank?(hash)
        hash.values.any?{|v| v.nil? || v.length == 0}
      end

      # TODO: Scrape more of what there is on the detail page
      def self.scrape_detail_page(page)
        {
          address: page.search('td.headerColumn[contains("Address")] ~ td').inner_text
        }
      end

      def self.scrape_index_page(page, info_url)
        results = page.search("tr.normalRow, tr.alternateRow")
        results.each do |result|
          yield(
            council_reference: result.search("td")[0].inner_text.to_s,
            description: result.search("td")[2].inner_text.to_s.squeeze(' '),
            info_url: info_url + URI::encode_www_form_component(result.search("td")[0].inner_text),
            date_received: Date.parse(result.search("td")[1]).to_s
          )
        end
      end

      # TODO: Inline this
      def self.scrape_and_save_index_page(page, agent_detail_page, info_url)
        scrape_index_page(page, info_url) do |record_index|
          detail_page = agent_detail_page.get(record_index[:info_url])
          record_detail = scrape_detail_page(detail_page)
          record = {
            'council_reference' => record_index[:council_reference],
            'address' => record_detail[:address],
            'description' => record_index[:description],
            'info_url' => record_index[:info_url],
            'date_scraped' => Date.today.to_s,
            'date_received' => record_index[:date_received]
          }
          if has_blank?(record)
            puts 'Something is blank, skipping record ' + record['council_reference']
            puts record
          else
            TechnologyOneScraper.save(record)
          end
        end
      end

      def self.scrape_and_save
        period = "TM"

        url         = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=$P1.ETR.SEARCH.S' + period
        info_url    = 'https://noo-web.t1cloud.com/T1PRDefault/WebApps/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=$P1.ETR.APPDET.VIW&ApplicationId='

        agent = Mechanize.new
        agent_detail_page = Mechanize.new
        page = agent.get(url)

        while page
          scrape_and_save_index_page(page, agent_detail_page, info_url)
          page = Page::Index.next(page)
        end
      end
    end
  end
end
