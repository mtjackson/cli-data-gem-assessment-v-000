require 'pry'
require 'nokogiri'
require 'open-uri'

class Scraper

  def self.get_page
    Nokogiri::HTML(open("https://www.nytimes.com/books/best-sellers/"))
  end

  def self.scrape_book_list
    scraped_books = []
    self.get_page.css("section.subcategory").each do |category|
      category_list = []
      genre = category.css("h2.subcategory-heading a").attribute("data-version").text
      category_list << genre
      category.css("li").each do |book|
        if book.css("h3.title").text != ""
          category_list << {
            :title => book.css("h3.title").text,
            :author => book.css("p.author").text,
            :description => book.css("p.description").text,
            :book_url => book.css("button").attribute("data-localbookstore").text
          }
        end
      end
      scraped_books << category_list
    end
    scraped_books
  end

  def self.scrape_book_details(book_url)
    book_scraper = Nokogiri::HTML(open(book_url))
    book_details = {}

    book_details[:summary] = book_scraper.css("div.book-top-section").css("div")[8].text
    if book_scraper.css("div.book-top-section").css("div")[9].text.include?("Buy at Local Store") == false
      book_details[:about_author] = book_scraper.css("div.book-top-section").css("div")[9].text
    end
    book_details[:rating] = book_scraper.css("div.rating-summary h2")

    book_details
  end
  #For more info, use indiebound.org link
  #Description: h4 class="blurgb-listname" (text = Description)
  #About Author: h4 class="blurgb-listname" (text = About the Author)
  #What Reviewers Say: div class="rating-summary" h2 text
end
