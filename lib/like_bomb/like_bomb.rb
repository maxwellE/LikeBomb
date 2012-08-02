require 'typhoeus'
require 'oj'
# LikeBomb, a fun way to mess with your friends on Facebook!  This gem can be 
# used to like and/or comment on every status and/or photo of one of your 
# Facebook friends!  
# @author Maxwell Elliott (mailto:elliott.432@buckeyemail.osu.edu)
# @license MIT
# @!attribute [r] key
#     @return [String] The FB Graph API Key used to create the LikeBomb
# 
# @!attribute [r] fb_name
#     @return [String] The Facebook user name of the owner of the current 
#         instance's Graph API key
# @example
#   lb = LikeBomb.new("<VALID_KEY>")
#   friend_hash = lb.get_friends 
#   unliked_statuses = lb.get_statuses(friend_hash["Tim Tom"])[:not_liked] # Get not liked statuses
#   lb.post_likes(unliked_statuses)
class LikeBomb
    attr_reader :key,:fb_name
  # @param [String] key A valid Facebook Graph API key which can be generated 
  #    {http://developers.facebook.com/tools/explorer here}, 
  #    please consult README for additional directions.
  # @raise [ArgumentError] if the provided Facebook Graph API key is invalid 
  #     due to insufficent permissions
  # @example Invalid key which will in turn throw an exception at runtime
  #     LikeBomb.new("HI") # "ArgumentError: The provided key is invalid..."
  # @example Valid key created by Billy Bob and used for a LikeBomb
  #    lb = LikeBomb.new("<VALID KEY>") 
  #    lb.fb_name # "Billy Bob"
  # @todo Use watir-webdriver to automate grabbing of keys from Graph API site.
  # Default String constructor
  def initialize(key)
    begin
      permissions = Oj.load(Typhoeus::Request.get(
        "https://graph.facebook.com/me/permissions?access_token=#{key}").body)["data"].first
      if is_valid?(permissions) 
        @key = key
        @fb_name = Oj.load(Typhoeus::Request.get(
            "https://graph.facebook.com/me?access_token=#{@key}").body)["name"] 
      else
        raise ArgumentError , 
          "The provided key is invalid, please consult the README for how to generate a valid API key"
      end
     rescue
        raise ArgumentError , 
          "The provided key is invalid, please consult the README for how to generate a valid API key"
     end
  end

  # @return [Hash<String,String>] a Hash containing all your friend's names as
  #     String keys and their unique ID as the corresponding String value
  # @example Let's grab Spongebob's friends
  #     spongebob_lb = LikeBomb.new("<SPONGEBOB_KEY>")
  #     spongebob_lb.get_friends # "{"Patrick" => "111231321221", Squidward" => "22212221222"}"
  # A method that can be used to retrieve user_id's of your friends.  You will 
  # need to use these ids to get status and/or photo object_ids
  def get_friends
    res = Typhoeus::Request.get(
               "https://graph.facebook.com/me/friends?access_token=#{@key}")
    unless res.nil?  
      json_data = Oj.load res.body
      friend_hash = Hash.new
      json_data["data"].each do |x|
        friend_hash[x["name"]] = x["id"]
      end
      return friend_hash
    end
  end
  # @return [Hash<Symbol,Array<String>>] a Hash of Symbol, Array<String> pairs.  
  #     Three keys exist, :all, :liked, :cooled, which represent all status ids, 
  #     status ids that are liked and status ids that have been commented 
  #     with "Cool!". These keys exist as to prevent double posting on a 
  #     specific status. Negations :not_liked and :not_cooled also exist
  # @param [String] user_id A user_id of one of your friends
  # @see get_friends
  # @example A typical use of get_statuses
  #     patrick_id = spongebob_lb.get_friends["Patrick"]
  #     spongebob_lb.get_statuses(patrick_id)[:all] # ["11123212333","33343444444",.....]
  # Grabs all statuses of a specific user when provided a user_id
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
    result_hash[:not_liked] = result_hash[:all] - result_hash[:liked]
    result_hash[:not_cooled] = result_hash[:all] - result_hash[:cooled]
    result_hash
  end
  # @return [Hash<Symbol,Array<String>>] a Hash of Symbol, Array<String> pairs.  
  #     Three keys exist, :all, :liked, :cooled, which represent all photo ids, 
  #     photo ids that are liked and photo ids that have been commented 
  #     with "Cool!". These keys exist as to prevent double posting on a 
  #     specific photo. Negations :not_liked and :not_cooled also exist
  # @param [String] user_id A user_id of one of your friends
  # @see get_friends
  # @example A typical use of get_photos
  #     patrick_id = spongebob_lb.get_friends["Patrick"]
  #     spongebob_lb.get_photos(patrick_id)[:all] # ["11123312333","33143444444",.....]
  # Grabs all photos of a specific user when provided a user_id
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
    result_hash[:not_liked] = result_hash[:all] - result_hash[:liked]
    result_hash[:not_cooled] = result_hash[:all] - result_hash[:cooled]
    result_hash
  end
  # @param [Array<String>] obj_ids an Array of Strings representing object_ids 
  #     of statuses and/or photos
  # @example common example
  #     unliked_ids = lb.get_statuses(friend_hash["Gumby"])[:not_liked] # Grab all previously unliked statuses
  #     lb.post_likes(unliked_ids) # Like all of Gumby's previously unliked statuses
  # Likes any provided object_id
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

  # @param [Array<String>] obj_ids an Array of Strings representing object_ids 
  #     of statuses and/or photos
  # @example common example
  #     unliked_ids = lb.get_photos(friend_hash["Gumby"])[:not_cooled] # Grab all previously uncommented photos
  #     lb.post_cools(unliked_ids) # Comment "Cool!" on all of Gumby's previously uncommented photos
  # Posts the comment "Cool!" on any provided object_id
  def post_cools(obj_ids)
     hydra = Typhoeus::Hydra.new
     complete_urls = obj_ids.collect{|id| "https://graph.facebook.com/#{id}/comments?access_token=#{@key}&publish_stream&message=Cool!"}   
     complete_urls.each do |url|
        Typhoeus::Request.post url
     end
  end

  private
  def is_valid?(permissions)
    result = false
    if permissions["publish_stream"] == 1 && permissions["friends_status"] == 1 &&
         permissions["friends_photos"] == 1 && permissions["user_likes"] == 1 && 
          permissions["publish_actions"] == 1 && permissions["read_stream"] ==1 && 
          permissions["export_stream"] == 1
        result = true
    end
    result 
  end

  def liked?(item)
    return item["likes"].nil? ? false : (item["likes"]["data"].collect{|x| x["name"]}.include? @fb_name)
  end

  def cooled?(item)
    return item["comments"].nil? ? false : (item["comments"]["data"].collect{|x| x["from"]["name"]}.include? @fb_name)
  end
end
