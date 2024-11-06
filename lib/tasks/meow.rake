def get_access_token()
  url = "https://api.qencode.com/v1/access_token"

  headers = {
    "accept": "application/json",
    "content-type": "application/x-www-form-urlencoded",
  }

  payload = {
    "api_key": "672531d48a4ea"
  }

  # Use faraday to post
  response = Faraday.post(url, payload, headers)
  json = JSON.parse(response.body, symbolize_names: true)

  if json[:error] == 1
    puts "Error: #{json[:error]}"
    return
  end

  token = json[:token]

  return token
end

def create_task(token:)
  url = "https://api.qencode.com/v1/create_task"

  headers = {
    "accept": "application/json",
    "content-type": "application/x-www-form-urlencoded",
  }

  payload = {
    "token": token,
  }

  # Use faraday to post
  response = Faraday.post(url, payload, headers)
  json = JSON.parse(response.body, symbolize_names: true)

  if json[:error] == 1
    puts "Error: #{json[:error]}"
    return
  end

  puts response.body

  task_token = json[:task_token]

  return task_token
end

def start_task(token:, task:)
  url = "https://api.qencode.com/v1/start_encode2"

  query = {
    query: {
      source:  "https://org-dcmp-ciy.s3.amazonaws.com/development-Mac-Studio/projects/75/21593_Happy_House_of_Frightenstein_105_Playroom_Panic-UNMezz.mp4",
      format: [
        {
          output: "mp4",
          framerate: "29.97",
          size: "1280x720",
          destination: {
            url: "s3://s3.us-east-1.amazonaws.com/org-dcmp-ciy/qencode-test/happy.mp4",
            key: "AKIAUSTIHHADNJCHO3OA",
            secret: "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",
            permissions: "public-read"
          },
        }
      ]
    }
  }


  headers = {
    "accept": "application/json",
    "content-type": "application/x-www-form-urlencoded",
  }

  payload = {
    "task_token": task,
    "payload": "dcmp-ciy123",
    "query": query.to_json
  }

  puts payload.to_json

  # Use faraday to post
  response = Faraday.post(url, payload, headers)
  json = JSON.parse(response.body, symbolize_names: true)

  if json[:error] == 1
    puts "Error: #{json[:error]}"
    return
  end

  puts response.body

  return json
end

namespace :meow do
  desc "This is a rake task"
  task :go => :environment do
    token = get_access_token()
    puts token
    task = create_task(token: token)
    puts task
    foo = start_task(token: token, task: task)
  end
end