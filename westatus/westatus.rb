require "sinatra"
require "json"
require_relative './config.rb'
require_relative './weather.rb'

set :bind, "localhost"

config = Config.new

set :port, config.data["network"]["port"] || 40002

get "/" do
  return "hi particles"
end

weather = Weather.new(config) if config.data["weather"]["enabled"]

get "/weather" do
  return "Weather not enabled" unless weather

  return weather.get_weather()
end


