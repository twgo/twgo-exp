require 'github_api'
require 'net/http'
class ExpsWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers
  sidekiq_options retry: false

  def perform(repo)
    p 'ExpsWorker start'
    exp = Exp.find_by(repo: repo, status: 'added')
    exp_running = Exp.find_by(repo: repo, status: 'running')

    if exp && !exp_running
     exp.update(status: 'running')
     Round.find_by(jid: exp.upstream).down_streams.create(branch: exp.branch)
     create_exp_on_github exp
    end

    p 'ExpsWorker OK'
  end

  private

  def create_exp_on_github exp
    upstream_info = exp.upstream_info
    repo = exp.repo
    branch = exp.branch
    content = exp.content
    sha = exp.sha
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
                           sha: file.sha)
    sleep 10
    delete_branch(repo, temp_branch)
    exp.update(status: 'processed')
  end

  def create_branch(repo, temp_branch, sha)
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'], password: ENV['GITHUB_SECRET'])
    github_client.create_ref "twgo/#{repo}", "heads/#{temp_branch}", sha
  end

  def delete_branch(repo, temp_branch)
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'], password: ENV['GITHUB_SECRET'])
    github_client.delete_ref "twgo/#{repo}", "heads/#{temp_branch}"
  end
end
