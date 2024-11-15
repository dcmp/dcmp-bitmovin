
class RestClient
  def initialize(base_url, headers: {})
    @base_url = base_url
    @headers = headers
  end

  def post(path, data: nil)
    response = self.request(path, method: :post, data: data)
  end

  private

  def request(path, method:, data:)
    url = "#{@base_url}/#{path}"
    response = Faraday.send(method, url, data.to_json, @headers)
    JSON.parse(response.body)
  end
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

  class Bitmovin::Object
    attr_reader :id
    attr_reader :instance_path

    def instance_route(path)
      @instance_path = path
    end

    def self.route(path)
      @route = path
    end

    def self.route_path
      @route
    end

    def route_path
      @instance_path || self.class.route_path
    end
  end

  class Bitmovin::Stream < Bitmovin::Object
    def initialize(encoding_id:, input_id:, input_path:, config_id:)
      instance_route "encoding/encodings/#{encoding_id}/streams"

      @encoding_id = encoding_id
      @input_id = input_id
      @input_path = input_path
      @config_id = config_id
    end

    def save!
      response = Bitmovin.client.post(self.route_path, data: { inputStreams: [{ selectionMode: "AUTO", inputId: @input_id, inputPath: @input_path }], codecConfigId: @config_id })
      @id = response["data"]["result"]["id"]
    end
  end

  module Bitmovin::Muxings
  end


  class Bitmovin::Muxings::BaseMuxing < Bitmovin::Object
    attr_accessor :segment_length
    attr_accessor :streams

    def initialize(encoding_id:, streams: [], output_id:, output_path:, segment_length: 4)
      @encoding_id = encoding_id
      @streams = streams
      @output_id = output_id
      @output_path = output_path
      @segment_length = segment_length
    end

    def save!
      payload = {
        segmentLength: @segment_length,
        streams: @streams,
        outputs: [
          {
            outputId: @output_id,
            outputPath: @output_path,
          }
        ]
      }

      puts "Submitting payload..."
      puts payload.to_json

      response = Bitmovin.client.post(self.route_path, data: payload)
      puts response.to_json
      @id = response["data"]["result"]["id"]
    end
  end


  class Bitmovin::Muxings::FMP4 < Bitmovin::Muxings::BaseMuxing
    def initialize(encoding_id:, streams: [], output_id:, output_path:, segment_length: 4)
      super

      instance_route "encoding/encodings/#{encoding_id}/muxings/fmp4"
    end
  end

  class Bitmovin::Muxings::TS < Bitmovin::Muxings::BaseMuxing
    def initialize(encoding_id:, streams: [], output_id:, output_path:, segment_length: 4)
      super

      instance_route "encoding/encodings/#{encoding_id}/muxings/ts"
    end
  end

  class Bitmovin::DashManifest < Bitmovin::Object
    route "encoding/manifests/dash/default"

    def initialize(encoding_id:, output_id:, output_path:)
      @encoding_id = encoding_id
      @output_id = output_id
      @output_path = output_path
    end

    def save!
      payload = {
        encodingId: @encoding_id,
        manifestName: "manifest.mpd",
        outputs: [
          {
            outputId: @output_id,
            outputPath: @output_path,
          }
        ],
      }

      puts "Submitting payload..."
      puts payload.to_json

      response = Bitmovin.client.post(self.route_path, data: payload)
      puts response.to_json
      @id = response["data"]["result"]["id"]
    end
  end

  module Bitmovin::HLS
    AUDIO_DESCRIBED = "public.accessibility.describes-video"
  end

  class Bitmovin::HLS::Audio < Bitmovin::Object
    def initialize(manifest_id:, group_id:, language: "en", name:, default: false, segment_path:, encoding_id:, stream_id:, muxing_id:, uri:, characteristics: [])
      instance_route "encoding/manifests/hls/#{manifest_id}/media/audio"

      @group_id = group_id
      @language = language
      @name = name
      @default = default
      @segment_path = segment_path
      @encoding_id = encoding_id
      @stream_id = stream_id
      @muxing_id = muxing_id
      @uri = uri
      @manifest_id = manifest_id
      @characteristics = characteristics
    end

    def save!
      payload = {
        groupId: @group_id,
        language: @language,
        name: @name,
        default: @default,
        segmentPath: @segment_path,
        encodingId: @encoding_id,
        streamId: @stream_id,
        muxingId: @muxing_id,
        uri: @uri,
        characteristics: @characteristics
      }

      response = Bitmovin.client.post(self.route_path, data: payload)
      @id = response["data"]["result"]["id"]
    end
  end

  class Bitmovin::HLSManifest < Bitmovin::Object
    route "encoding/manifests/hls"

    def initialize(encoding_id:, output_id:, output_path:)
      @encoding_id = encoding_id
      @output_id = output_id
      @output_path = output_path
    end

    def build_stream(muxing_id:, stream_id:, uri:, segment_path:)
      Bitmovin::HLSVariantStream.new(manifest_id: @id, encoding_id: @encoding_id, muxing_id: muxing_id, stream_id: stream_id, segment_path: segment_path, uri: uri)
    end

    def build_audio_stream(group_id:, language: "en", name:, default: false, segment_path:, stream_id:, muxing_id:, uri:, characteristics: [])
      Bitmovin::HLS::Audio.new(manifest_id: @id, group_id: group_id, language: language, name: name, default: default, segment_path: segment_path, encoding_id: @encoding_id, stream_id: stream_id, muxing_id: muxing_id, uri: uri, characteristics: characteristics)
    end

    def save!
      payload = {
        encodingId: @encoding_id,
        manifestName: "playlist.m3u8",
        outputs: [
          {
            outputId: @output_id,
            outputPath: @output_path,
          }
        ],
      }

      puts payload.to_json
      puts self.route_path

      response = Bitmovin.client.post(self.route_path, data: payload)
      puts response.to_json
      @id = response["data"]["result"]["id"]
    end
  end

  class Bitmovin::HLSVariantStream < Bitmovin::Object
    def initialize(manifest_id:, encoding_id:, muxing_id:, stream_id:, segment_path:, uri:, closed_captioning: 'NONE')
      instance_route "encoding/manifests/hls/#{manifest_id}/streams"

      @manifest_id = manifest_id
      @encoding_id = encoding_id
      @muxing_id = muxing_id
      @stream_id = stream_id
      @segment_path = segment_path
      @uri = uri
      @closed_captioning = closed_captioning
    end

    def save!
      payload = {
        encodingId: @encoding_id,
        muxingId: @muxing_id,
        streamId: @stream_id,
        segmentPath: @segment_path,
        uri: @uri,
        closedCaptions: @closed_captioning
      }

      response = Bitmovin.client.post(self.route_path, data: payload)
      @id = response["data"]["result"]["id"]
    end
  end

  class Bitmovin::Encoding < Bitmovin::Object
    route "encoding/encodings"

    attr_accessor :name

    def initialize(name:)
      @name = name
    end

    def build_hls_manifest(output_id:, output_path:)
      Bitmovin::HLSManifest.new(encoding_id: @id, output_id: output_id, output_path: output_path)
    end

    def build_dash_manifest(output_id:, output_path:)
      Bitmovin::DashManifest.new(encoding_id: @id, output_id: output_id, output_path: output_path)
    end

    def build_stream(input_id:, input_path:, config_id:)
      Bitmovin::Stream.new(encoding_id: @id, input_id: input_id, input_path: input_path, config_id: config_id)
    end

    def build_ts_muxing(output_id:, output_path:, segment_length: 4, streams: [])
      Bitmovin::Muxings::TS.new(encoding_id: @id, streams: streams, output_id: output_id, output_path: output_path, segment_length: segment_length)
    end

    def build_fmp4_muxing(output_id:, output_path:, segment_length: 4, streams: [])
      Bitmovin::Muxings::FMP4.new(encoding_id: @id, streams: streams, output_id: output_id, output_path: output_path, segment_length: segment_length)
    end

    def save!
      response = Bitmovin.client.post(self.class.route_path, data: { name: @name })
      @id = response["data"]["result"]["id"]
    end
  end
end

namespace :thing do
  desc "whatever"
  task :whatever => :environment do
    input_id  = "014265ce-9925-44e8-8579-609d7549b177"
    output_id = "968b5efc-1865-470f-8a7e-68f11cb93b68"

    ladder = [
      { name: "something", id: "701e7dab-c6eb-439a-9f18-2fa8c0ef2ab5" },
      { name: "something_two", id: "701e7dab-c6eb-439a-9f18-2fa8c0ef2ab5" }
    ]

    Bitmovin.init("d36d4b40-997a-4a26-ab5f-91d1f8156e51")
    encoding = Bitmovin::Encoding.new(name: "Elephant")
    encoding.save!
    puts "Encoding: #{encoding.id}"

    streams = {}
    muxings = {}
    fmp4_muxings = {}

    audio_stream = encoding.build_stream(input_id: input_id, input_path: "production/projects/13/exports/description/en/en_description_track.mp3", config_id: "b5b8710d-5c2b-4aa5-8592-2124b2a8cafb")
    audio_stream.save!
    puts "Audio Stream: #{audio_stream.id}"

    audio_muxing = encoding.build_fmp4_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/audio/en_described")
    audio_muxing.streams << audio_stream.id
    audio_muxing.save!
    puts "Audio Muxing: #{audio_muxing.id}"


    main_audio_stream = encoding.build_stream(input_id: input_id, input_path: "production/projects/13/program_audio.wav", config_id: "b5b8710d-5c2b-4aa5-8592-2124b2a8cafb")
    main_audio_stream.save!
    puts "Audio Stream: #{main_audio_stream.id}"
    main_audio_muxing = encoding.build_fmp4_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/audio/en_main")
    main_audio_muxing.streams << main_audio_stream.id
    main_audio_muxing.save!
    puts "Audio Muxing: #{main_audio_muxing.id}"

    ladder.each do |config|
      stream = encoding.build_stream(input_id: input_id, input_path: "production/projects/13/10255_All_About_The_Holidays_Labor_Day-UNMezz.mp4", config_id: config[:id])
      stream.save!

      streams[config[:name]] = stream
      puts "Stream: #{stream.id}"

      # muxing = encoding.build_ts_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/hls/#{config[:name]}")
      # muxing.streams << stream.id
      # muxing.save!

      # muxings[config[:name]] = muxing
      # puts "Muxing: #{muxing.id}"

      fmp4_muxing = encoding.build_fmp4_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/fmp4/#{config[:name]}")
      fmp4_muxing.streams << stream.id
      fmp4_muxing.save!
      fmp4_muxings[config[:name]] = fmp4_muxing
      puts "FMP4 Muxing: #{fmp4_muxing.id}"
    end

    hls_manifest = encoding.build_hls_manifest(output_id: output_id, output_path: "maia-bitmovin-test/project")
    hls_manifest.save!
    puts "HLS Manifest: #{hls_manifest.id}"

    # dash_manifest = encoding.build_dash_manifest(output_id: output_id, output_path: "maia-bitmovin-test/project")
    # dash_manifest.save!
    # puts "Dash Manifest: #{dash_manifest.id}"

    audio_media = hls_manifest.build_audio_stream(
      group_id: "audio_group_0",
      name: "English",
      segment_path: "audio/en_main",
      stream_id: main_audio_stream.id,
      muxing_id: main_audio_muxing.id,
      language: "en",
      uri: "en_main.m3u8",
      default: true
    )
    audio_media.save!
    puts "Audio Media: #{audio_media.id}"

    described_audio_media = hls_manifest.build_audio_stream(
      group_id: "audio_group_1",
      name: "English (Described)",
      segment_path: "audio/en_described",
      stream_id: audio_stream.id,
      muxing_id: audio_muxing.id,
      language: "en",
      uri: "en_described.m3u8",
      default: false,
      characteristics: [Bitmovin::HLS::AUDIO_DESCRIBED]
    )
    described_audio_media.save!
    puts "Audio Media: #{described_audio_media.id}"



    ladder.each do |config|
      variant_stream = hls_manifest.build_stream(muxing_id: fmp4_muxings[config[:name]].id, stream_id: streams[config[:name]].id, uri: "#{config[:name]}.m3u8", segment_path: "fmp4/#{config[:name]}")
      variant_stream.save!
      puts "Variant Stream: #{variant_stream.id}"
    end
  end

end