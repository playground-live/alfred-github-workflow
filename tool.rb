# give some tool for github
module Tool

  module_function
  # test the auth token
  def test_authentication
    load_token
    return false if !@token || @token.length == 0
    res = get "/"
    !res.has_key?('error')
  end

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
end
