require 'nokogiri'
require 'feedzirra'
require 'open-uri'
require 'grape'
require 'logger'

$logger = Logger.new(STDOUT)

module KudosHelper

  def is_svbtle?(entry)
    Nokogiri::HTML(open(entry.url)).search("figure div.num")[0] ? true : false
  end

end

class Kudos < Grape::API
  format :json
  helpers KudosHelper

  params do
    requires :url, type: String, desc: "URL of a blog to get, in the form of 'aley.me'"
  end
  get :blog do
     
    feed = Feedzirra::Feed.fetch_and_parse("http://#{params[:url]}/feed")
    if is_svbtle?(feed.entries.first)

      posts = Array.new

      feed.entries.each do |post|
        count = Nokogiri::HTML(open(post.url)).search("figure div.num")[0].inner_html
        posts << { title: post.title, url: post.url, kudos: count }
      end

      present posts
    else
      $logger.info("#{params[:url]} isn't a svbtle blog.")
      status 400
      "Do you even Svbtle, bro?"
    end
  end
end
