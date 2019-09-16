require 'sinatra'

#gem 'sinatra-reloader'
require 'sinatra/reloader'
configure :production do
enable :reloader
end

# session
enable :sessions
# h
include ERB::Util

require 'omniauth'
require 'omniauth-twitter'

#http://sinatrarb.com/contrib/config_file
require "sinatra/config_file"
config_file 'config/twitter.yml'

use OmniAuth::Builder do
    provider :twitter,
    settings.API_KEY, settings.API_SECRET
end

get '/auth/twitter/callback' do
    auth = env['omniauth.auth']
    session[:auth]={:uid=>auth.uid,:name=>auth.info.name}
    redirect '/'
end

before do
    if request.path_info.start_with? '/auth/' then return end 
    if session.include? :auth then
        @name=session[:auth][:name]
    else
        redirect '/auth/twitter'
    end
end

set :public_folder, 'public' #public/favicon.ico
get '/' do
    erb :index #views/index.erb
end
