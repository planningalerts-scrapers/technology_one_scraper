# frozen_string_literal: true

require "active_support/core_ext/hash"

module TechnologyOneScraper
  module Page
    # A list of results of a search
    module Index
      def self.scrape(page, webguest = "P1.WEBGUEST")
        table = page.at("table.grid")
        Table.extract_table(table).each do |row|
          council_reference = row["Application Link"] ||
                              row["ID"]
          params = {
            # The first two parameters appear to be required to get the
            # correct authentication to view the page without a login or session
            "r" => webguest,
            "f" => "$P1.ETR.APPDET.VIW",
            "ApplicationId" => council_reference
          }
          info_url = "eTrackApplicationDetails.aspx?#{params.to_query}"
          date_received = row["Lodgement Date"] ||
                          row["Lodged"]
          address = row["Formatted Address"] ||
                    row["Property Address"] ||
                    row["Address"]
          yield(
            "council_reference" => council_reference,
            "address" => address,
            "description" => row["Description"].squeeze(" "),
            "info_url" => (page.uri + info_url).to_s,
            "date_scraped" => Date.today.to_s,
            "date_received" => Date.strptime(date_received, "%d/%m/%Y").to_s
          )
        end
      end

      def self.next(page)
        i = extract_current_page_no(page)
        link = find_link_for_page_number(page, i + 1)
        Postback.click(link, page) if link
      end

      def self.extract_current_page_no(page)
        page.search("tr.pagerRow").search("td span").inner_text.to_i
      end

      # Find the link to the given page number (if it's there)
      def self.find_link_for_page_number(page, number)
        links = page.search("tr.pagerRow").search("td a, td span")
        # Let's find the link with the required page
        texts = links.map(&:inner_text)
        number_texts = texts.reject { |t| t == "..." }
        max_page = number_texts.max_by(&:to_i).to_i
        min_page = number_texts.min_by(&:to_i).to_i
        if number == min_page - 1 && texts[0] == "..."
          links[0]
        elsif number >= min_page && number <= max_page
          links.find { |l| l.inner_text == number.to_s }
        elsif number == max_page + 1 && texts[-1] == "..."
          links[-1]
        end
      end
    end
  end
end
