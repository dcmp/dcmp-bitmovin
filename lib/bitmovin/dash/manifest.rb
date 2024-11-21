class Bitmovin::Dash::Manifest < Bitmovin::Object
  route "encoding/manifests/dash"

  param :output_id
  param :output_path

  option :name
  option :description
  option :custom_data
  option :manifest_name, default: "manifest.mpd"

  def build_period
    Bitmovin::Dash::Period.new(manifest_id: @id)
  end

  def start!
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

    response = Bitmovin.client.post("encoding/manifests/dash/#{@id}/start", data: payload)

    if response["status"] == "ERROR"
      raise Bitmovin::Error.new(response["data"]["message"])
    end

    id = response["data"]["result"]["id"]
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