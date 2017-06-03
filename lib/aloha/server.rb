require 'open-uri'

module Aloha
  class Server < SlackRubyBot::Server

    HOOK_HANDLERS = {
      hello: Aloha::Hooks::LoadMessages.new
    }

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
          try_send_message(client, msg["label"], msg["text"], user_id, username)
        end
      end
    end

    def self.try_send_message client, label, text, id, username
      message = Message.find_by(label: label)
      user = User.find_by(slack_id: id)
      if user.ready_for?(message) && !user.received?(message)
        say(client, username, text)
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
      Message.all.each do |msg|
        try_send_message(client, msg.label, msg.content, id, username)
      end
    end

    def self.say client, username, text, options={}
      options.merge!(text: text, channel: "@#{username}", as_user: true, link_names: true)
      client.web_client.chat_postMessage(options)
    end

    def self.messages; @messages; end

  end
end
