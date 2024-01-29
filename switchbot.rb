require 'securerandom'
require 'openssl'
require 'base64'
require 'httpclient'
require 'json'

class Command
    API_HOST =  "https://api.switch-bot.com"
    TOKEN = ENV["SWITCHBOT_TOKEN"]
    SECRET = ENV["SWITCHBOT_SECRET"]
    HTTP_CLIENT = HTTPClient.new

    def fetch_devices
        filename = "device-list.json"            

        # 空ファイルもしくは更新日時から一日経過した場合、APIをリクエスト投げる
        # APIレスポンスをJSONファイルに書き込む
        if File.empty?(filename) || File.mtime(filename) + (60 * 60 * 24) < Time.now()
        
            begin
                url = "#{API_HOST}/v1.1/devices"
                response = HTTP_CLIENT.get(url, header: generate_header)
            rescue => e
                raise e
            end
    
            File.open(filename, "w") do |text|
                text.puts(response.body)
            end
        end

        File.open(filename) do |f|
          JSON.load(f)
        end
    end

    def toggleLight
        device_id = get_device_id(deviceName: "ライト")

        # 電気ON/OFFのリクエスト作成する
        url = "#{API_HOST}/v1.1/devices#{device_id}/commands"
        body = JSON.generate({
            command: "turnOn",
            parameter: "default",
            commandType: "command"
        })
    end

    private 
        def generate_header
            t = (Time.now.to_f * 1000).to_i
            nonce = SecureRandom.uuid
            payload = "#{TOKEN}#{t}#{nonce}"
            signature = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", SECRET, payload))

            { Authorization: TOKEN, sign: signature, nonce: nonce, t: t}
        end

        def get_device_id(deviceName:)
            begin
                devices = fetch_devices["body"]["deviceList"]
                device = devices.find { |d| d["deviceName"] == deviceName}
                device["deviceId"]
            rescue => e
                raise "JSONのキーが不正です。確認してください。"
            end
        end
end

com = Command.new()

# 部屋の電気ON/OFF
com.toggleLight