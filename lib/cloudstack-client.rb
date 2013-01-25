require 'cloudstack-client/version'
require 'cloudstack-client/api'

apikey='yy0sfCPpyKnvREhgpeIWzXORIIvyteq_iCgFpKXnqpdbnHuoYiK78nprSggG4hcx-hxwW897nU-XvGB0Tq8YFw'
seckey='Pse4fqYNnr1xvoRXlAe8NQKCSXeK_VGdwUxUzyLEPVQ7B3cI1Q7B8jmZ42FQpz2jIICFax1foIzg2716lJFZVw'

module Cloudstack
  module Client
    class CloudStackClient

      def initialize(api_url, api_key, secret_key, use_ssl)
        @api_url = api_url
        @api_key = api_key
        @secret_key = secret_key
        @use_ssl = use_ssl
      end

      def send_request(params)
        params['response'] = 'json'
        params['apiKey'] = @api_key

        params_arr = []
        params.sort.each { |elem|
          params_arr << elem[0].to_s + '=' + elem[1].to_s
        }
        data = params_arr.join('&')
        encoded_data = URI.encode(data.downcase).gsub('+', '%20').gsub(',', '%2c')
        signature = OpenSSL::HMAC.digest('sha1', @secret_key, encoded_data)
        signature = Base64.encode64(signature).chomp
        signature = CGI.escape(signature)

        url = "#{@api_url}?#{data}&signature=#{signature}"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        #http.use_ssl = @use_ssl
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        if !response.is_a?(Net::HTTPOK) then
          puts "Error #{response.code}: #{response.message}"
          puts JSON.pretty_generate(JSON.parse(response.body))
          puts "URL: #{url}"
          exit 1
        end

        json = JSON.parse(response.body)
        json[params['command'].downcase + 'response']
      end

      def list_servers
        params = {
            'command' => 'listVirtualMachines'
        }
        json = send_request(params)
        json['virtualmachine'] || []
        return json
      end

      def hi
        puts list_servers
        return "Hi there!"
      end

    end
  end
end
