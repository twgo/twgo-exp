require 'github_api'
require 'net/http'

class GgithubsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @upstream = Round.where(repo: 'DNN-train').where.not(rate: [888, 999]).order(id: :desc) || Round.none
    if params[:select_repo] = 'true'
      origin_downstreams = get_branches "twgo/DNN-test"
      hidden_branches = Rails.configuration.my_hidden_branches
      @downstreams = origin_downstreams.select{ |b| (hidden_branches.exclude? b[:down_name]) }
    end
    origin_code = get_dockerfile(params[:repo], params[:sha])
    repo_ver = 'DNN-train:'
    @github_code = params[:upstream].blank? ? origin_code : origin_code.split("\n")[0..-1].map{ |x|
      if x.include?(repo_ver)
        "FROM dockerhub.iis.sinica.edu.tw/#{repo_ver}#{params[:upstream].split('/')[-1]}"
      else
        x
      end
    }.join("\n")

    if params[:downstream]
      @round_in_history = Round.where(id: DownStream.where(branch: params[:downstream].split('oooo')[0]).pluck(:round_id)).order(id: :desc)
    end
  end

  def update
    Exp.create(
      upstream: params[:github_code][:upstream],
      upstream_info: params[:github_code][:upstream_info],
      repo: params[:github_code][:repo],
      branch: params[:github_code][:branch],
      content: params[:github_code][:content],
      sha: params[:github_code][:sha],
      status: 'added'
    )

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

    sleep 8

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
