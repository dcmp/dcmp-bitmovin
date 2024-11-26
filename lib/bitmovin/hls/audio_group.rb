class Bitmovin::HLS::AudioGroup
  def initialize(name:, priority: 50)
    @name = name
    @priority = priority
  end

  def build_payload
    {
      name: @name,
      priority: @priority
    }
  end
end