require "json"
require "net/http"
require "uri"
require "fileutils"
require "zlib"
require "base64"

require_relative "pincode_finder/config"
require_relative "pincode_finder/github_client"

module PincodeFinder
  DATA_FILE = File.expand_path("../data/pincode_data_optimized.json.gz", __dir__)
  DETAILS_HASH = "{ district: <district>, state: <state>}".freeze

  def self.find(pincode)
    pincode = pincode.to_s
    data = load_data

    record = data[pincode]

    if record
      {
        pincode: pincode,
        state: record["state"],
        district: record["district"],
        verified: record["verified"] || true
      }
    else
      {
        error: "Pincode not found",
        message: "You can add it using: PincodeFinder.add_pincode(#{pincode}, #{DETAILS_HASH})"
      }
    end
  end

  def self.add_pincode(pincode, input_details)
    pincode = pincode.to_s
    input_details = normalize_and_filter(input_details)

    data = load_data
    record = data[pincode]

    return { status: "failure", error: "Pincode already present in the directory" } unless record.nil?

    verified, error = validate_pincode(pincode, input_details)
    return { status: "failure", error: error } unless error.nil?

    data[pincode] = input_details.merge("verified" => verified)

    save_data(data)

    sync_to_github(data)

    {
      status: "success",
      data: data[pincode],
      error: nil
    }
  end

  def self.validate_pincode(pincode, input_details)
    verified, api_data = verify_pincode(pincode)
    return [false, nil] unless verified

    status, error = input_details_validation(api_data, input_details)
    return [false, error] unless status

    [verified, nil]
  end

  def self.verify_pincode(pincode)
    begin
      uri = URI("https://api.postalpincode.in/pincode/#{pincode}")

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                                     open_timeout: 3, read_timeout: 3) do |http|
        http.get(uri.request_uri)
      end

      return [false, nil] unless response.is_a?(Net::HTTPSuccess)

      json = JSON.parse(response.body) rescue nil
      return [false, nil] unless json.is_a?(Array) && json[0].is_a?(Hash)

      status = json[0]["Status"]
      return [false, nil] unless status == "Success"

      po = json[0]["PostOffice"]
      return [false, nil] unless po.is_a?(Array) && po[0].is_a?(Hash)

      details = po[0].slice("Division", "District", "State")

      [true, details]
    rescue StandardError
      [false, nil]
    end
  end

  def self.update_pincode(pincode, input_details)
    pincode = pincode.to_s
    input_details = normalize_and_filter(input_details)
    data = load_data

    record = data[pincode]
    return { status: "failure", error: "pincode not found" } unless record

    verified, error = validate_pincode(pincode, input_details)
    return { status: "failure", error: error } unless error.nil?

    data[pincode] = input_details.merge("verified" => verified)
    save_data(data)
    sync_to_github(data)

    {
      status: "success",
      data: data[pincode],
      error: nil
    }
  end

  def self.delete_pincode(pincode)
    pincode = pincode.to_s
    data = load_data

    record = data[pincode]
    return { status: "failure", error: "pincode not found" } unless record

    data.delete(pincode)

    save_data(data)
    sync_to_github(data)

    {
      status: "success",
      data: {},
      error: nil
    }
  end

  def self.input_details_validation(data, input_details)
    input_state     = input_details["state"].to_s.titleize
    input_district  = input_details["district"].to_s.titleize

    api_state       = data["State"].to_s.titleize
    api_district    = data["District"].to_s.titleize
    api_division    = data["Division"].to_s.titleize

    return [false, "Incorrect state. Allowed: #{api_state}"] unless input_state == api_state

    unless input_district == api_district || input_district == api_division
      return [
        false,
        "Incorrect district. Allowed: #{api_district} or #{api_division}"
      ]
    end

    [true, nil]
  end

  def self.load_data
    Zlib::GzipReader.open(DATA_FILE) { |gz| JSON.parse(gz.read) }
  end

  def self.save_data(json)
    json_string = JSON.pretty_generate(json)

    Zlib::GzipWriter.open(DATA_FILE) do |gz|
      gz.write(json_string)
    end
  end

  def self.normalize_and_filter(input_details)
    input_details
      .transform_keys { |k| k.to_s.downcase }
      .slice("district", "state")
  end

  def self.sync_to_github(data)
    Thread.new do
      begin
        client = GitHubClient.new

        remote = client.get_file_with_sha
        sha    = remote[:sha]

        client.update_file(data, sha)
      rescue StandardError
        nil
      end
    end
  end
end
