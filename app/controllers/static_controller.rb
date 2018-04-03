class StaticController < ApplicationController
  def editor
    # link github
    @github_code = get_github
    # read data
  end

  private

  def get_github
    require 'github_api'
    require 'net/http'

    contents = Github::Client::Repos::Contents.new oauth_token: ENV['GITHUB_TOKEN']
    code = contents.get 'leo424y', 'playground', 'README.md'

    Net::HTTP.get(URI.parse(code.download_url)).force_encoding("UTF-8")
  end
end
