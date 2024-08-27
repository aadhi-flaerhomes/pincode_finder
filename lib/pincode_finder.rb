# frozen_string_literal: true
require "json"
require 'zlib'
require_relative "pincode_finder/version"

module PincodeFinder
  class Error < StandardError; end
  data_file = File.expand_path('../data/pincode_data.json.gz', __dir__)

  DATA = Zlib::GzipReader.open(data_file) do |gz|
    JSON.parse(gz.read)
  end

  def self.find(pincode)
    result = DATA.find { |entry| entry["pincode"].to_s == pincode.to_s }
    if result
      {
        pincode: result["pincode"],
        district: result["district"],
        state: result["state"]
      }
    else
      { error: "Pincode not found" }
    end
  end
end
