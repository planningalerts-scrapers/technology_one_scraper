# frozen_string_literal: true

module TechnologyOneScraper
  module Page
    # A list of results of a search
    module Index
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
