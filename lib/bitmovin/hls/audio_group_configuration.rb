class Bitmovin::HLS::AudioGroupConfiguration
  def initialize(dropping_mode: "STREAM", groups:)
    @dropping_mode = dropping_mode
    @groups = groups
  end

  def build_payload
    {
      droppingMode: @dropping_mode,
      groups: @groups.map(&:build_payload)
    }
  end

  def to_json
    build_payload
  end
end