# give some tool for github
module Request
  # communicate with github by get
  def get(path, params = {})
    params['per_page'] = 100
    qs = params.map { |k, v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
    uri = URI("#{@base_uri}#{path}?#{qs}")
    json_all = []

    begin
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req['Accept'] = 'application/vnd.github.v3+json'
        req['Authorization'] = "token #{@token}"
        http.request(req)
      end

      json = JSON.parse(res.body)

      return { 'error' => json['message'] } unless res.kind_of? Net::HTTPSuccess

      if json.is_a?(Array)
        json_all.concat json
        uri = URI((res['link'].match /<([^>]+)>;\s*rel="next"/ )[1]) rescue nil
        break if uri.nil?
      else
        json_all = json
        break
      end
    end while true
    json_all
  end

  def post(path,query)
    uri = URI.parse("#{@base_uri}#{path}")
    http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request.body = { 'title' => query }.to_json

    response = http.request(request)

    url = response.body
    JSON.parse(url)['html_url']
  end
end
