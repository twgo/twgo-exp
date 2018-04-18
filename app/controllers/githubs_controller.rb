require 'github_api'
require 'net/http'

class GithubsController < ApplicationController
  def index
    origin_code = get_dockerfile(params[:repo], params[:sha])
    @github_code = params[:upstream].blank? ? origin_code : origin_code.split("\n")[1..-1].unshift("FROM localhost:5000/siann1-hak8_boo5-hing5:#{params[:upstream].split('/')[-1]}").join("\n")

    @round = Round.where(id: params[:rid]) || Round.none
    @upstream = Round.where(repo: 'siann1-hak8_boo5-hing5') || Round.none
  end

  def update
    message = "EXP RUN: #{params[:github_code][:upstream_info]}"
    github_contents = Github::Client::Repos::Contents.new oauth_token: ENV['GITHUB_TOKEN']
    file = github_contents.get 'twgo', params[:github_code][:repo], 'Dockerfile', ref: params[:github_code][:branch]

    github_contents.update('twgo', params[:github_code][:repo], 'Dockerfile',
      path: 'Dockerfile',
      branch: params[:github_code][:branch],
      message: message,
      content: params[:github_code][:content],
      sha: file.sha,
    )

    redirect_to rounds_path
  end

  private

  def get_dockerfile repo, sha
    url = "https://raw.githubusercontent.com/twgo/#{repo}/#{sha}/Dockerfile"
    Net::HTTP.get(URI.parse(URI.unescape(URI.encode(url)))).force_encoding("UTF-8")
  end
end
