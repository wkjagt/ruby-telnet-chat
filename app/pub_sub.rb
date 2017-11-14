require 'redis'
require 'json'

module App
  class PubSub
    def initialize
      @pub_redis = Redis.new(host: "localhost", port: 6379, db: 1)
      @sub_redis = Redis.new(host: "localhost", port: 6379, db: 1)
    end

    def publish(message)
      @pub_redis.publish('chat-messages',message.to_json)
    end

    def listen
      Thread.new do
        @sub_redis.subscribe('chat-messages') do |on|
          on.message { |_, msg| yield(JSON.parse(msg)) }
        end
      end
    end
  end
end
