require 'open-uri'

module Aloha
  class Server < SlackRubyBot::Server
    on 'hello' do
      load_messages!
    end

    on 'team_join' do |client, message|
      username = client.users[message.user].name
      user_id = client.users[message.user].id
      if username != client.name
        welcome_new_user(client, user_id, username)
      end
    end

    on 'presence_change' do |client, message|
      username = client.users[message.user].name
      user_id = client.users[message.user].id
      if username != client.name && message.presence == 'active' && initialized?(username)
        messages.each do |msg|
          try_send_message(client, msg, user_id, username)
        end
      end
    end

    def self.try_send_message client, msg, id, username
      message = Message.find_by(label: msg["label"])
      user = User.find_by(slack_id: id)
      if user.ready_for?(message) && !user.received?(message)
        say(client, username, msg["text"])
        Delivery.where(message: message, user: user).first_or_create!
      end
    end

    def self.initialized?(username)
      return User.where(username: username).exists?
    end

    def self.welcome_new_user client, id, username
      u = User.where(slack_id: id).first_or_initialize
      u.update_attributes!(username: username)

      say(client, username, "Welcome to #{client.team.name}!")
      messages.each do |msg|
        try_send_message(client, msg, id, username)
      end
    end

    def self.say client, username, text, options={}
      options.merge!(text: text, channel: "@#{username}", as_user: true, link_names: true)
      client.web_client.chat_postMessage(options)
    end

    def self.load_messages!
      config_file = ENV['MESSAGES_CONFIG_FILE'] || File.join($ROOT_FOLDER, "config/messages.json")
      data = open(config_file).read
      @messages = JSON::parse(data)
      @messages.each do |msg|
        message = Message.where(label: msg["label"]).first_or_initialize
        message.content = msg["text"]
        message.delay = msg["delay"]
        message.save!
      end
    end

    def self.messages; @messages; end

  end
end
