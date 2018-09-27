require 'github_api'
require 'net/http'

class GgithubsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @upstream = Round.where(repo: 'DNN-train').where.not(rate: [0, 888, 999]).order(id: :desc) || Round.none
    if params[:select_repo] = 'true'
      origin_downstreams = get_branches "twgo/DNN-test"
      hidden_branches = Rails.configuration.my_hidden_branches
      @downstreams = origin_downstreams.select{ |b| (hidden_branches.exclude? b[:down_name]) }
    end
    origin_code = get_dockerfile(params[:repo], params[:sha])
    @github_code = params[:upstream].blank? ? origin_code : origin_code.split("\n")[1..-1].unshift("FROM dockerhub.iis.sinica.edu.tw/DNN-train:#{params[:upstream].split('/')[-1]}").join("\n")

    if params[:downstream]
      @round_in_history = Round.where(id: DownStream.where(branch: params[:downstream].split('oooo')[0]).pluck(:round_id)).order(id: :desc)
    end
  end

  def update
    Round.find_by(jid: params[:github_code][:upstream]).down_streams.create(branch: params[:github_code][:branch])

    create_exp_on_github params[:github_code][:upstream_info], params[:github_code][:repo], params[:github_code][:branch], params[:github_code][:content], params[:github_code][:sha]

    redirect_to ggithubs_path(select_down: 'yes'), notice: "實驗已建立!"
  end

  def create_exp_on_github upstream_info, repo, branch, content, sha
    temp_branch = "_#{branch}"
    create_branch(repo, temp_branch, sha)

    message = "EXP RUN: #{upstream_info}"
    github_contents = Github::Client::Repos::Contents.new oauth_token: ENV['GITHUB_TOKEN']
    file = github_contents.get 'twgo', repo, 'Dockerfile', ref: branch

    github_contents.update('twgo', repo, 'Dockerfile',
      path: 'Dockerfile',
      branch: temp_branch,
      message: message,
      content: content,
      sha: file.sha,
    )

    sleep 2

    delete_branch(repo, temp_branch)
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

  def create_branch repo, temp_branch, sha
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    github_client.create_ref "twgo/#{repo}", "heads/#{temp_branch}", sha
  end

  def delete_branch repo, temp_branch
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    github_client.delete_ref "twgo/#{repo}", "heads/#{temp_branch}"
  end
end