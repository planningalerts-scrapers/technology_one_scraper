require 'scraperwiki'
require 'mechanize'

module TechnologyOneScraper
  module Authority
    module Cockburn
      def self.postback(form, target, argument)
        form['__EVENTTARGET'] = target
        form['__EVENTARGUMENT'] = argument
        form.submit
      end

      def self.scrape_and_save_index_page(page, info_url)
        results = page.search("tr.normalRow, tr.alternateRow")
        results.each do |result|
          record = {
            'council_reference' => result.search("td")[0].inner_text.to_s,
            'address'           => result.search("td")[3].inner_text.to_s,
            'description'       => result.search("td")[2].inner_text.to_s,
            'info_url'          => info_url + result.search("td")[0].inner_text.sub!("/", "%2f"),
            'date_scraped'      => Date.today.to_s,
            'date_received'     => Date.parse(result.search("td")[1]).to_s
          }

          TechnologyOneScraper.save(record)
        end
      end

      def self.extract_postback(link)
        link['href'].scan(/'([^']*)'/).flatten
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
        else
          raise "Couldn't find link"
        end
      end

      def self.scrape_and_save
        period = "TM"

        url         = 'https://ecouncil.cockburn.wa.gov.au/eProperty/P1/eTrack/eTrackApplicationSearchResults.aspx?Field=S&Period=' + period +'&r=P1.WEBGUEST&f=%24P1.ETR.SEARCH.S' + period
        info_url    = 'https://ecouncil.cockburn.wa.gov.au/eProperty/P1/eTrack/eTrackApplicationDetails.aspx?r=P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId='

        agent = Mechanize.new
        page = agent.get(url)

        if page.search("tr.pagerRow").empty?
          puts 'Nothing to scape'
          exit 0
        end

        while page.search("tr.pagerRow").search("td")[-1].inner_text == '...' do
          links = page.search("tr.pagerRow").search("td a")
          target, argument = extract_postback(links[-1])
          page = postback(page.form, target, argument)
        end
        totalPages = page.search("tr.pagerRow").search("td")[-1].inner_text.to_i

        (1..totalPages).each do |i|
          puts "Scraping page " + i.to_s + " of " + totalPages.to_s

          if i == 1
            page = agent.get(url)
          else
            link = find_link_for_page_number(page, i)
            target, argument = extract_postback(link)
            page = postback(page.form, target, argument)
          end

          scrape_and_save_index_page(page, info_url)
        end
      end
    end
  end
end
