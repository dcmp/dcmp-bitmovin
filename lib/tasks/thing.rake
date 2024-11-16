
namespace :thing do
  desc "whatever"
  task :whatever => :environment do
    input_id  = "014265ce-9925-44e8-8579-609d7549b177"
    output_id = "968b5efc-1865-470f-8a7e-68f11cb93b68"

    ladder = [
      { name: "something", id: "701e7dab-c6eb-439a-9f18-2fa8c0ef2ab5" },
      { name: "something_two", id: "701e7dab-c6eb-439a-9f18-2fa8c0ef2ab5" }
    ]

    audio_config_id = "b5b8710d-5c2b-4aa5-8592-2124b2a8cafb"

    project = {
      audio: [
        {
          input_id: input_id,
          filename: "production/projects/13/program_audio.wav",
          language: "en",
          name: "English",
          default: true,
        },
        {
          input_id: input_id,
          filename: "production/projects/13/exports/description/en/en_description_track.mp3",
          language: "en",
          name: "English (Described)",
          default: false,
        }
      ],
      video: "production/projects/13/10255_All_About_The_Holidays_Labor_Day-UNMezz.mp4",
      subtitles: []
    }

    Bitmovin.init("d36d4b40-997a-4a26-ab5f-91d1f8156e51")

    encoding = Bitmovin::Encoding.new(name: "Labor Day")
    encoding.save!

    # ---

    main_audio_stream = encoding.build_stream(input_id: input_id, input_path: "production/projects/13/program_audio.wav", codec_config_id: audio_config_id)
    main_audio_stream.save!

    main_audio_muxing = encoding.build_fmp4_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/audio/en_main")
    main_audio_muxing.streams << main_audio_stream.id
    main_audio_muxing.save!

    # ---

    description_stream = encoding.build_stream(input_id: input_id, input_path: "production/projects/13/exports/description/en/en_description_track.mp3", codec_config_id: audio_config_id)
    description_stream.save!

    description_muxing = encoding.build_fmp4_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/audio/en_described")
    description_muxing.streams << description_stream.id
    description_muxing.save!

    # ---

    fmp4_muxings = {}
    video_streams = {}
    ladder.each do |config|
      stream = encoding.build_stream(input_id: input_id, input_path: "production/projects/13/10255_All_About_The_Holidays_Labor_Day-UNMezz.mp4", codec_config_id: config[:id])
      stream.save!

      fmp4_muxing = encoding.build_fmp4_muxing(output_id: output_id, output_path: "maia-bitmovin-test/project/fmp4/#{config[:name]}")
      fmp4_muxing.streams << stream.id
      fmp4_muxing.save!

      fmp4_muxings[config[:name]] = fmp4_muxing
      video_streams[config[:name]] = stream
    end

    # ---

    hls_manifest = encoding.build_hls_manifest(output_id: output_id, output_path: "maia-bitmovin-test/project")
    hls_manifest.save!

    # ---

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

    described_audio_media = hls_manifest.build_audio_stream(
      group_id: "audio_group_1",
      name: "English (Described)",
      segment_path: "audio/en_described",
      stream_id: description_stream.id,
      muxing_id: description_muxing.id,
      language: "en",
      uri: "en_described.m3u8",
      default: false,
      characteristics: [Bitmovin::HLS::AUDIO_DESCRIBED]
    )
    described_audio_media.save!

    # ---

    ladder.each do |config|
      variant_stream = hls_manifest.build_stream(muxing_id: fmp4_muxings[config[:name]].id, stream_id: video_streams[config[:name]].id, uri: "#{config[:name]}.m3u8", segment_path: "fmp4/#{config[:name]}")
      variant_stream.save!
      puts "Variant Stream: #{variant_stream.id}"
    end
  end
end