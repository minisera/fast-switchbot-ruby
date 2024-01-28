require 'securerandom'
require 'openssl'
require 'base64'
require 'httpclient'
require 'json'

class Command
    API_HOST =  "https://api.switch-bot.com"
    TOKEN = ENV["SWITCHBOT_TOKEN"]
    SECRET = ENV["SWITCHBOT_SECRET"]

    def fetch_devices
        client = HTTPClient.new
        url = "#{API_HOST}/v1.1/devices"
        filename = "device-list.json"            

        # 空ファイルもしくは更新日時から一日経過した場合、APIをリクエスト投げる
        # APIレスポンスをJsonファイルに書き込む
        if File.empty?(filename) || File.mtime(filename) + (60 * 60 * 24) < Time.now()
        
            begin
                response = client.get(url, header: generate_header)
            rescue => e
                raise e
            end
    
            File.open(filename, "w") do |text|
                text.puts(response.body)
            end
        end

        file = File.open(filename, "r")
        puts file.read
    end

    private 
        def generate_header
            t = (Time.now.to_f * 1000).to_i
            nonce = SecureRandom.uuid
            payload = "#{TOKEN}#{t}#{nonce}"
            signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SECRET, payload))

            { Authorization: TOKEN, sign: signature, nonce: nonce, t: t }
        end
end

com = Command.new()
com.fetch_devices