class GarbageDay
  def self.notify
    message = if Date.today.tuesday? || Date.today.friday?
      "今日は燃えるゴミの日です"
    elsif Date.today.wednesday?
      "今日は資源ゴミの日です"
    end
    return if message.blank?

    client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_GARBAGE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_GARBAGE_CHANNEL_TOKEN']
    end

    client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": message})
  end
end
