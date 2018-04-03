require 'github_api'
require 'net/http'

class GithubsController < ApplicationController
  def index
    # link github
    params[:branch] = 'siann0102'
    @github_code = params[:branch] ? (get_dockerfile 'gi2-gian5_boo5-hing5', params[:branch]) : ''
    # read data
  end

  def update
    params[:branch] = 'siann0102'
    params[:repo] = 'gi2-gian5_boo5-hing5'

    contents = Github::Client::Repos::Contents.new oauth_token: ENV['GITHUB_TOKEN']
    file = contents.get 'twgo', params[:repo], 'Dockerfile', ref: params[:branch]
    contents.update('twgo', params[:repo], 'Dockerfile', path: 'Dockerfile', branch: params[:branch], message: 'EXP commit', content: params[:github_code][:content], sha: file.sha)
    redirect_to rounds_path
  end

  private

  def get_dockerfile project, branch
    # url = "https://raw.githubusercontent.com/twgo/#{project}/#{branch}/Dockerfile"
    #
    # Net::HTTP.get(URI.parse(URI.escape(url))).force_encoding("UTF-8")

    contents = Github::Client::Repos::Contents.new oauth_token: ENV['GITHUB_TOKEN']
    url = contents.get(user: 'twgo', repo: project, path: 'Dockerfile', ref: branch).download_url

    Net::HTTP.get(URI.parse(URI.escape(url))).force_encoding("UTF-8")
  end
end
