require 'typhoeus'
require 'oj'
class LikeBomb
  attr_accessor :key
  def initialize(key)
    @key = key
  end

  def get_friends
    res = Typhoeus::Request.get("https://graph.facebook.com/me/friends?access_token=#{@key}")
    unless res.nil?  
      json_data = Oj.load res.body
      return json_data["data"]
    end
  end

  def get_statuses(user_id)
    all_statuses = []
    all_links = []
    res = Typhoeus::Request.get("https://graph.facebook.com/#{user_id}/statuses?access_token=#{@key}")
    take_statuses = Oj.load(res.body)["data"].empty? ? false : true
    while take_statuses
      Oj.load(res.body)["data"].each do |status|
        unless all_statuses.include? status["id"]
          all_statuses.push status["id"]
        end
      end
      next_url = Oj.load(res.body)["paging"]["next"]
      if all_links.include? next_url || next_url.nil?
        take_statuses = false
      else
        all_links.push next_url
        res = Typhoeus::Request.get("#{Oj.load(res.body)["paging"]["next"]}?access_token=#{@key}")
      end
    end
    all_statuses
  end

  def get_photos(user_id)
    all_photos = []
    all_links = []
    res = Typhoeus::Request.get("https://graph.facebook.com/#{user_id}/photos?access_token=#{@key}")
    take_photos = Oj.load(res.body)["data"].empty? ? false : true
    while take_photos
      unless Oj.load(res.body)["data"].nil?
        Oj.load(res.body)["data"].each do |photo|
          unless all_photos.include? photo["id"]
            all_photos.push photo["id"]
          end
        end
      end
      begin
        next_url = Oj.load(res.body)["paging"]["next"]
      rescue NoMethodError
        break
      end
      if all_links.include? next_url || next_url.nil?
        take_photos = false
      else
        all_links.push next_url
        res = Typhoeus::Request.get("#{Oj.load(res.body)["paging"]["next"]}?access_token=#{@key}")
      end
    end
    all_photos
  end
  def post_likes(obj_ids)
     hydra = Typhoeus::Hydra.new
     complete_urls = obj_ids.collect{|id| "https://graph.facebook.com/#{id}/likes?access_token=#{@key}&publish_stream"}   
     complete_urls.each do |url|
       hydra.queue Typhoeus::Request.new(url,
                                       :method => :post,
                                       :timeout => 5000,
                                       :cache_timeout => 60)
     end
     hydra.run
  end

  def post_cools(obj_ids)
     hydra = Typhoeus::Hydra.new
     complete_urls = obj_ids.collect{|id| "https://graph.facebook.com/#{id}/comments?access_token=#{@key}&publish_stream&message=Cool!"}   
     complete_urls.each do |url|
       hydra.queue Typhoeus::Request.new(url,
                                       :method => :post,
                                       :timeout => 5000,
                                       :cache_timeout => 60)
     end
     hydra.run
  end
  def post_likes_and_cools(obj_ids)
     hydra = Typhoeus::Hydra.new
     complete_urls = obj_ids.collect{|id| "https://graph.facebook.com/#{id}/comments?access_token=#{@key}&publish_stream&message=Cool!"}   
     complete_urls.concat obj_ids.collect{|id| "https://graph.facebook.com/#{id}/likes?access_token=#{@key}&publish_stream"}
     complete_urls.each do |url|
       hydra.queue Typhoeus::Request.new(url,
                                       :method => :post,
                                       :timeout => 5000,
                                       :cache_timeout => 60)
     end
     hydra.run
  end
end

def main
  lb = LikeBomb.new("KEYHERE")
  lb.get_friends.each do |friend|
    puts "Bombing #{friend["name"]}: #{Time.now}"
    all_ids = lb.get_statuses(friend["id"])
    all_ids.concat lb.get_photos(friend["id"])
      lb.post_likes_and_cools(all_ids)
    puts "Done bombing #{friend["name"]}: #{Time.now}"
  end
end
if __FILE__ == $0
  main
end
