require 'bundler/setup'
Bundler.require(:default, :development)

require 'json'
require 'active_support/all'
require 'sinatra'

Dir['./config/initialisers/*.rb'].each { |f| require f }

class App < Sinatra::Base

  before do
    halt 401, 'Access denied' unless $APP_CONFIG.api_keys.include? params[:api_key]
    @api_key = params[:api_key]
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/new-relic' do
    if params['deployment'] || params['alert']

      if params['deployment']
        d = Hashie::Mash.new(JSON(params['deployment']))
        title = "Deployment for #{d.application_name} by #{d.deployed_by}"
        message = Tilt.new(File.join('.', 'views', 'new-relic', 'deployment.erb')).render(d)
      elsif params['alert']
        d = Hashie::Mash.new(JSON(params['alert']))
        title = "Alert for #{d.application_name} - #{d.short_description}"
        message = Tilt.new(File.join('.', 'views', 'new-relic', 'alert.erb')).render(d)
      end

      Pushover.notification(message: message, title: title, user: config.user_key, token: config.api_key)
    end
    ''
  end

  private

  def config
    $APP_CONFIG.pushover
  end
end
