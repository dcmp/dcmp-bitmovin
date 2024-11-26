# frozen_string_literal: true

require "bundler/setup"

require "bitmovin/rest_client"
require "bitmovin/object"
require "bitmovin/encoding"
require "bitmovin/stream"
require "bitmovin/muxing"
require "bitmovin/muxing/fmp4"
require "bitmovin/muxing/chunked_text"
require "bitmovin/hls"
require "bitmovin/hls/audio"
require "bitmovin/hls/vtt"
require "bitmovin/hls/manifest"
require "bitmovin/hls/variant_stream"
require "bitmovin/hls/audio_group"
require "bitmovin/hls/audio_group_configuration"
require "bitmovin/dash"
require "bitmovin/dash/audio_adaptation_set"
require "bitmovin/dash/period"
require "bitmovin/dash/manifest"
require "bitmovin/dash/representation"
require "bitmovin/dash/representation/fmp4"
require "bitmovin/dash/representation/vtt"
require "bitmovin/dash/video_adaptation_set"
require "bitmovin/dash/subtitle_adaptation_set"
require "bitmovin/file_input_stream"

require_relative "bitmovin/version"

module Bitmovin
  class Error < StandardError; end
  # Your code goes here...
end

module Bitmovin
  def self.init(api_key)
    @@api_key = api_key
    @@client = RestClient.new("https://api.bitmovin.com/v1", headers: {
      "accept": "application/json",
      "content-type": "application/json",
      "X-Api-Key": api_key
    })
  end

  def self.api_key
    @@api_key
  end

  def self.client
    @@client
  end
end