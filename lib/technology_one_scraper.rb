require "technology_one_scraper/version"
require "technology_one_scraper/authority/wyndham"

module TechnologyOneScraper
  def self.scrape_and_save(authority)
    case authority
    when :wyndham
      Authority::Wyndham.scrape_and_save
    else
      raise "Unexpected authority: #{authority}"
    end
  end
end
