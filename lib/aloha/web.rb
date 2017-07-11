require 'aloha/controllers/helpers'

require 'aloha/controllers/index'
require 'aloha/controllers/install'
require 'aloha/controllers/welcome'
require 'aloha/controllers/wizard'
require 'aloha/controllers/login'
require 'aloha/controllers/logout'
require 'aloha/controllers/messages'

module Aloha
  class Web < Sinatra::Base
    configure do
      # allow "delete" method with _method param in POST request
      use Rack::MethodOverride

      set :sessions, true
      use Rack::Session::Cookie, :key => 'rack.session',
                                 :domain => URI.parse(ENV['BASE_URL']).host,
                                 :path => '/',
                                 :expire_after => 2592000,
                                 :secret => ENV['SESSION_SECRET']

      set :views, Proc.new { File.join(ENV['ROOT_FOLDER'], "lib", "aloha", "views") }
      set :public_folder, Proc.new { File.join(ENV['ROOT_FOLDER'], "public") }
    end

    helpers do
      def current_user
        @user ||= User.find_by(token: session[:slack_user_token])
      end

      def logged_in?
        session[:slack_user_token] && current_user
      end

      def require_login!
        if session[:slack_user_token].nil?
          redirect '/'
        end
      end
    end
  end
end