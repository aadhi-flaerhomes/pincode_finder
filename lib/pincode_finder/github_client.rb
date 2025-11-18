require "net/http"
require "uri"
require "json"
require "base64"

module PincodeFinder
  class GitHubClient
    def initialize
      @owner = PincodeFinder.config.github_owner
      @repo  = PincodeFinder.config.github_repo
      @token = PincodeFinder.config.github_token
      @api = "https://api.github.com"
      @file = "pincode_data_optimized.json.gz"
    end

    def get_file_with_sha
      uri = URI("#{@api}/repos/#{@owner}/#{@repo}/contents/data/#{@file}")

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "token #{@token}"
      req["Accept"] = "application/vnd.github+json"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }

      return { json: {}, sha: nil } unless res.is_a?(Net::HTTPSuccess)

      data = JSON.parse(res.body)
      content = Base64.decode64(data["content"])

      json_string = Zlib::GzipReader.new(StringIO.new(content)).read

      { json: JSON.parse(json_string), sha: data["sha"] }
    end

    def update_file(json_data, sha)
      json_string = JSON.pretty_generate(json_data)

      # compress
      string_io = StringIO.new
      gz = Zlib::GzipWriter.new(string_io)
      gz.write(json_string)
      gz.close
      compressed = string_io.string

      encoded = Base64.strict_encode64(compressed)

      uri = URI("#{@api}/repos/#{@owner}/#{@repo}/contents/data/#{@file}")

      body = {
        message: "Update #{@file}",
        content: encoded,
        sha: sha,
        branch: "main"
      }

      req = Net::HTTP::Put.new(uri)
      req["Authorization"] = "token #{@token}"
      req["Accept"] = "application/vnd.github+json"
      req.body = body.to_json

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
    end
  end
end
