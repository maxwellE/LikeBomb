require 'curb'
require 'oj'
class LikeBomb
  attr_accessor :key
  def initialize(key)
    @key = key
  end
  def get_friends
    res = Curl.get("https://graph.facebook.com/me/friends?access_token=#{@key}")
    unless res.nil?  
    json_data = Oj.load res.body_str
    return json_data["data"]
    end
  end
  def get_statuses(user_id)
    all_statuses = []
    all_links = []
    take_statuses = true
    res = Curl.get("https://graph.facebook.com/#{user_id}/statuses?access_token=#{@key}")
    if Oj.load(res.body_str)["data"].empty?
      take_statuses=false
    end
    while take_statuses
      Oj.load(res.body_str)["data"].each do |status|
        unless all_statuses.include? status["id"]
          all_statuses.push status["id"]
        end
      end
      next_url = Oj.load(res.body_str)["paging"]["next"]
      if all_links.include? next_url || next_url.nil?
        take_statuses = false
      else
        all_links.push next_url
        res = Curl.get("#{Oj.load(res.body_str)["paging"]["next"]}?access_token=#{@key}")
      end
    end
    all_statuses
  end
  def post_like(obj_id)
     Curl.post("https://graph.facebook.com/#{obj_id}/likes?access_token=#{@key}&publish_stream")
  end
  def post_cool(obj_id)
     Curl.post("https://graph.facebook.com/#{obj_id}/comments?access_token=#{@key}&publish_stream&message=Cool!")
  end
end
def main
  lb = LikeBomb.new("<ACCESS_TOKEN_HERE>")
  lb.get_friends.each do |friend|
    puts "Bombing #{friend["name"]}: #{Time.now}"
    lb.get_statuses(friend["id"]).each do |status_id|
    #  lb.post_cool(status_id)
      lb.post_like(status_id)
    end
    puts "Done bombing #{friend["name"]}: #{Time.now}"
  end
end
if __FILE__ == $0
  main
end
