require 'securerandom'
require 'openssl'
require 'base64'
require 'httpclient'
require 'json'

class Command
    API_HOST =  "https://api.switch-bot.com"
    TOKEN = ENV["SWITCHBOT_TOKEN"]
    SECRET = ENV["SWITCHBOT_SECRET"]

    def getDevices
        client = HTTPClient.new
        url = "#{API_HOST}/v1.1/devices"
        response = client.get(url, header: generateHeader)
        puts JSON.parse(response.body)
    end

    private 
        def generateHeader
            t = (Time.now.to_f * 1000).to_i
            nonce = SecureRandom.uuid
            payload = "#{TOKEN}#{t}#{nonce}"
            signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SECRET, payload))

            { Authorization: TOKEN, sign: signature, nonce: nonce, t: t }
        end
end

com = Command.new()
com.getDevices