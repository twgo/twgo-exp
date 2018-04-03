require 'github_api'
require 'net/http'

class StaticController < ApplicationController
  def editor
    # link github
    @github_code = get_github 'twgo', 'gi2-gian5_boo5-hing5', 'Dockerfile'
    # read data
  end

  def update

  end

  private

  def get_github repo, project, file
    contents = Github::Client::Repos::Contents.new oauth_token: ENV['GITHUB_TOKEN']
    code = contents.get repo, project, file

    Net::HTTP.get(URI.parse(code.download_url)).force_encoding("UTF-8")
  end
end
