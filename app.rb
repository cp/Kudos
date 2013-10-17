require 'nokogiri'
require 'feedzirra'
require 'open-uri'
require 'grape'
require 'logger'
require 'dalli'
require 'memcachier'

$logger = Logger.new(STDOUT)

module KudosHelper

  def cache
    Dalli::Client.new(ENV["MEMCACHIER_SERVERS"].split(","),
                    {username: ENV["MEMCACHIER_USERNAME"],
                     password: ENV["MEMCACHIER_PASSWORD"],
                     namespace: 'kudos',
                     compress: true,
                     expires_in: 180
                    })
  end

  def is_svbtle?(entry)
    Nokogiri::HTML(open(entry.url)).search("figure div.num")[0] ? true : false
  end

  def cache_and_get(url)
    if posts = cache.get(url)
      posts
      $logger.info "Read #{url} from cache."
    else
      posts = Array.new
      feed.entries.each do |post|
        count = Nokogiri::HTML(open(post.url)).search("figure div.num")[0].inner_html
        posts << { title: post.title, url: post.url, kudos: count }
      end
      cache.set(url, posts)
      $logger.info "Cached #{url}"
      posts
    end
  end

end

class Kudos < Grape::API
  format :json
  helpers KudosHelper

  params do
    requires :url, type: String, desc: "URL of a blog to get, in the form of 'aley.me'"
  end
  get :blog do
     
    feed_url = "http://#{params[:url]}/feed"
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)

    if is_svbtle?(feed.entries.first)
      posts = cache_and_get(feed_url)
      present posts
    else
      $logger.info("#{params[:url]} isn't a svbtle blog.")
      status 400
      "Doesn't appear to be a Svbtle blog."
    end

  end

end
