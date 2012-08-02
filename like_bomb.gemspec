Gem::Specification.new do |s|
  s.name        = 'like_bomb'
  s.version     = '0.0.0'
  s.date        = '2012-07-25'
  s.summary     = "Lets annoy some Facebook friends"
  s.description = "Likebomb is a quick and efficent way to annoy your Facebook friends by liking or commenting on every status and/or photo 
  belonging to them.  This gem is a great example of the possiblites with the new Facebook Graph API."
  s.author    = "Maxwell Elliott"
  s.email       = 'elliott.432@buckeyemail.osu.edu'
  s.files       = Dir["lib/**/*.rb"]
  s.homepage    =
    'http://rubygems.org/gems/like_bomb'
  s.license     = 'MIT'
  s.post_install_message = 'Thanks for using LikeBomb! Have fun!'
  s.required_ruby_version = '>=1.8.7'
  s.requirements << 'A Facebook account'
  s.requirements << 'A Facebook Developer Graph API key'
  s.add_runtime_dependency "typhoeus", ["= 0.4.2"]
  s.add_runtime_dependency "oj", ["= 1.3.0"]
  s.test_files = Dir.glob('test/like*.rb')
  s.extra_rdoc_files = ['README']
end
