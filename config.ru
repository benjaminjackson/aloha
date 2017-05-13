require 'slack-ruby-bot'

class AlohaBot < SlackRubyBot::Bot
end

class AlohaServer < SlackRubyBot::Server
  on 'team_join' do |client, message|
    username = client.users[message.user].name
    if username != client.name
      say(client, username, "Welcome to #{client.team.name}!")
    end
  end

  def self.say client, username, text
    client.web_client.chat_postMessage(text: text, channel: "@#{username}", as_user: true)
  end
end

AlohaBot.run
run AlohaServer.new
