require 'github_api'
require 'net/http'

class GithubsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @upstream = Round.where(repo: 'siann1-hak8_boo5-hing5').where.not(rate: '0.0').where.not(rate: '999.0') || Round.none
    if params[:select_repo] = 'true'
      @downstreams = get_branches "twgo/gi2-gian5_boo5-hing5"
    end
    origin_code = get_dockerfile(params[:repo], params[:sha])
    @github_code = params[:upstream].blank? ? origin_code : origin_code.split("\n")[1..-1].unshift("FROM localhost:5000/siann1-hak8_boo5-hing5:#{params[:upstream].split('/')[-1]}").join("\n")

    if params[:downstream]
      @round_in_history = Round.where(id: DownStream.where(branch: params[:downstream].split('oooo')[0]).ids)
    end
  end

  def update
    Round.find_by(jid: params[:github_code][:upstream]).down_streams.create(branch: params[:github_code][:branch])
    
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

    redirect_to githubs_path(select_down: 'yes'), notice: "實驗已建立!"
  end

  private

  def get_dockerfile repo, sha
    url = "https://raw.githubusercontent.com/twgo/#{repo}/#{sha}/Dockerfile"
    Net::HTTP.get(URI.parse(URI.unescape(URI.encode(url)))).force_encoding("UTF-8")
  end

  def get_branches org_repo
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    github_client.branches(org_repo).map{ |x| {
      down_name: x[:name],
      down_sha: x[:commit][:sha],
      }}
  end
end
