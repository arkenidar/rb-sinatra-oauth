require 'sinatra'

#gem 'sinatra-reloader'
require 'sinatra/reloader'
configure :production do
enable :reloader
end

=begin
for security
- run as unpriviledged user (not root)
- set :environment, :production # debuggable means being open
this could be useful as well
- set :bind, 'localhost' # as it runs behind Apache with
  ProxyPass /ruby http://localhost:4567
=end
set :environment, :production
set :bind, 'localhost'
#set :port, 4567

# session
enable :sessions
# h
include ERB::Util

require 'omniauth'
require 'omniauth-twitter'

#http://sinatrarb.com/contrib/config_file
require "sinatra/config_file"
config_file 'config/twitter.yml'
config_file 'config/url.yml'

use OmniAuth::Builder do
    provider :twitter,
    settings.API_KEY, settings.API_SECRET
end

get '/auth/twitter/callback' do
    auth = env['omniauth.auth']
    session[:auth]={:uid=>auth.uid,:name=>auth.info.name}
    redirect settings.after_login
end

before do
    if request.path_info.start_with? '/auth/' then return end 
    if session.include? :auth then
        @name=session[:auth][:name]
    else
        redirect '/auth/twitter/'
    end
end

set :public_folder, 'public' #public/favicon.ico
get '/' do
    erb :index #views/index.erb
end
