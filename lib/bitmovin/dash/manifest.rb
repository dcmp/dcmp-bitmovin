class Bitmovin::Dash::Manifest < Bitmovin::Object
  route "encoding/manifests/dash"

  param :output_id
  param :output_path

  option :name
  option :description
  option :custom_data
  option :manifest_name, default: "manifest.mpd"

  class << self
    def find(id)
      response = Bitmovin.client.get("encoding/manifests/dash/#{id}")

      if response["status"] == "ERROR"
        raise Bitmovin::Error.new(response["data"]["message"])
      end

      result = response["data"]["result"]

      # Convert keys into snake-case symbols
      result = Hash[result.map { |k, v| [k.to_s.underscore.to_sym, v] }]

      return new(result)
    end
  end

  def build_period
    Bitmovin::Dash::Period.new(manifest_id: @id)
  end

  def self.start!(manifest_id)
    payload = {
      "trimming": {
        "ignoreDurationIfInputTooShort": false
      },
      "tweaks": {
        "audioVideoSyncMode": "RESYNC_AT_START_AND_END"
      },
      "encodingMode": "STANDARD",
      "manifestGenerator": "V2"
    }

    response = Bitmovin.client.post("encoding/manifests/dash/#{manifest_id}/start", data: payload)

    if response["status"] == "ERROR"
      raise Bitmovin::Error.new(response["data"]["message"])
    end

    id = response["data"]["result"]["id"]
  end

  def start!
    Bitmovin::Dash::Manifest.start!(@id)
  end

protected

  def build_payload
    {
      manifestName: self.manifest_name,
      outputs: [
        {
          outputId: self.output_id,
          outputPath: self.output_path,
        }
      ],
    }
  end
end