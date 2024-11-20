
namespace :thing do
  desc "whatever"
  task :whatever => :environment do
    input_id  = "014265ce-9925-44e8-8579-609d7549b177"
    output_id = "968b5efc-1865-470f-8a7e-68f11cb93b68"

    ladder = [
      { name: "360px_320000", id: "af1a6a99-10db-41b3-b2e3-8d96d3edd704" },
      { name: "576px_512000", id: "70128f28-d054-4538-b63f-f3cb79312e96" },
      { name: "720px_880000", id: "dfe762d7-acc9-4ea1-bff2-3a58a34f33d4" },
      { name: "1080px_1600000", id: "57a856de-d411-497e-93bf-d425622942a5" },

    ]

    # 96k
    audio_config_id = "dbae7a23-c93f-4078-b648-b493ffb0c730"

    # 128k
    audio_config_id = "67e8c4b2-ec7f-4074-9dbf-8c73b9df63e8"

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

    # ---

    dash_manifest = encoding.build_dash_manifest(output_id: output_id, output_path: "maia-bitmovin-test/project")
    dash_manifest.save!
    puts "Dash Manifest: #{dash_manifest.id}"

    period = dash_manifest.build_period
    period.save!

    audio_adaptation_set = period.build_audio_adaptation_set
    audio_adaptation_set.save!

    audio_representation = audio_adaptation_set.build_fmp4_representation(
      encoding_id: encoding.id,
      muxing_id: main_audio_muxing.id,
      type: "TEMPLATE",
      segment_path: "audio/en_main"
    )
    audio_representation.save!

    described_audio_adaptation_set = period.build_audio_adaptation_set(
      roles: [Bitmovin::Dash::ROLE_ALTERNATE],
      accessibilities: [Bitmovin::Dash::ACCESSIBILITY_DESCRIPTIVE]
    )
    described_audio_adaptation_set.save!

    described_audio_representation = described_audio_adaptation_set.build_fmp4_representation(
      encoding_id: encoding.id,
      muxing_id: description_muxing.id,
      type: "TEMPLATE",
      segment_path: "audio/en_described"
    )
    described_audio_representation.save!


    ladder.each do |config|
      video_adaptation_set = period.build_video_adaptation_set
      video_adaptation_set.save!
      puts "Video Adaptation Set: #{video_adaptation_set.id}"

      representation = video_adaptation_set.build_fmp4_representation(
        encoding_id: encoding.id,
        muxing_id: fmp4_muxings[config[:name]].id,
        type: "TEMPLATE",
        segment_path: "fmp4/#{config[:name]}"
      )
      representation.save!
      puts "Representation: #{representation.id}"
    end
  end
end