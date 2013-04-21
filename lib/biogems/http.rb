module BioGemInfo

  module Http

    def self.get_http_body url
      uri = URI.parse(url)
      $stderr.print "Fetching #{url}\n"
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if response.code.to_i != 200
        $stderr.print "get_http_body not found for "+url
        return "{}"
      end
      response.body
    end

    def self.get_https_body url
      uri = URI.parse(url)
      $stderr.print "Fetching #{url}\n"
      https = Net::HTTP.new(uri.host, 443)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      https.ca_path = '/etc/ssl/certs' if File.exists?('/etc/ssl/certs') # Ubuntu
      https.ca_file = '/opt/local/share/curl/curl-ca-bundle.crt' if File.exists?('/opt/local/share/curl/curl-ca-bundle.crt') # Mac OS X
      https.read_timeout = 60
      request = Net::HTTP::Get.new(uri.request_uri)
      response = https.request(request)
      if response.code.to_i != 200
        $stderr.print "get_https_body not found for "+url
        return "{}"
      end
      response.body
    end


  end

end
