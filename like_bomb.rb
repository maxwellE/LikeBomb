require 'typhoeus'
require 'oj'
require 'pry'
class LikeBomb
  attr_accessor :key,:fb_name
  def initialize(key)
    @key = key
    @fb_name = Oj.load(Typhoeus::Request.get("https://graph.facebook.com/me?access_token=#{@key}").body)["name"] 
  end

  def get_friends
    res = Typhoeus::Request.get("https://graph.facebook.com/me/friends?access_token=#{@key}")
    unless res.nil?  
      json_data = Oj.load res.body
      return json_data["data"]
    end
  end

  def get_statuses(user_id)
    result_hash = Hash.new
    result_hash[:all] = []
    result_hash[:liked] = []
    result_hash[:cooled] = []
    all_links = []
    res = Typhoeus::Request.get("https://graph.facebook.com/#{user_id}/statuses?access_token=#{@key}")
    take_statuses = Oj.load(res.body)["data"].empty? ? false : true
    while take_statuses
      Oj.load(res.body)["data"].each do |status|
        unless result_hash[:all].include? status["id"]
          result_hash[:all].push status["id"]
          result_hash[:liked].push status["id"] if liked?(status)
          result_hash[:cooled].push status["id"] if cooled?(status)
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
    result_hash
  end

  def get_photos(user_id)
    result_hash = Hash.new
    result_hash[:all] = []
    result_hash[:liked] = []
    result_hash[:cooled] = []
    all_links = []
    res = Typhoeus::Request.get("https://graph.facebook.com/#{user_id}/photos?access_token=#{@key}")
    take_photos = Oj.load(res.body)["data"].empty? ? false : true
    while take_photos
      unless Oj.load(res.body)["data"].nil?
        Oj.load(res.body)["data"].each do |photo|
          unless result_hash[:all].include? photo["id"]
            result_hash[:all].push photo["id"]
            result_hash[:liked].push photo["id"] if liked?(photo)
            result_hash[:cooled].push photo["id"] if cooled?(photo)
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
    result_hash
  end
  def post_likes(obj_ids)
     hydra = Typhoeus::Hydra.new
     complete_urls = obj_ids.collect{|id| "https://graph.facebook.com/#{id}/likes?access_token=#{@key}&publish_stream"}   
     complete_urls.each do |url|
       hydra.queue Typhoeus::Request.new(url,
                                       :method => :post,
                                       :timeout => 50000,
                                       :cache_timeout => 60)
     end
     hydra.run
  end

  def post_cools(obj_ids)
     hydra = Typhoeus::Hydra.new
     complete_urls = obj_ids.collect{|id| "https://graph.facebook.com/#{id}/comments?access_token=#{@key}&publish_stream&message=Cool!"}   
     complete_urls.each do |url|
        Typhoeus::Request.post url
     end
  end

  private

  def liked?(item)
    return item["likes"].nil? ? false : (item["likes"]["data"].collect{|x| x["name"]}.include? @fb_name)
  end

  def cooled?(item)
    return item["comments"].nil? ? false : (item["comments"]["data"].collect{|x| x["from"]["name"]}.include? @fb_name)
  end
end

def main
  lb = LikeBomb.new(IO.readlines("key.txt").first)
  lb.get_friends.select{|f| f["name"] == "Matt Leckner"}.each do |friend|
    puts "Bombing #{friend["name"]}: #{Time.now}"
    all_ids = (lb.get_statuses(friend["id"])[:all] - lb.get_statuses(friend["id"])[:cooled])
    all_ids.concat(lb.get_photos(friend["id"])[:all] - lb.get_photos(friend["id"])[:cooled])
    lb.post_cools(all_ids)
    puts "Done bombing #{friend["name"]}: #{Time.now}"
  end
end
if __FILE__ == $0
  main
end
