class RestaurantsController < ApplicationController
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery except: [:show]

  def show
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # 入力した文字をinputに格納
          input = event.message['text']
          if input == ("全て" || "すべて" || "全部")
            client.reply_message(event['replyToken'], {"type": "text", "text": "これまでのすべてのレストランをお送りします"})
            message = Restaurant.create_line_messages(Restaurant.all.ids)
          else
          # 入力された文字で店名を検索し、lineメッセージを作成する
          restaurants_ids = Restaurant.where("name like ?", "%#{input}%").ids
          message = Restaurant.create_line_messages(restaurants_ids)
          end
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end
