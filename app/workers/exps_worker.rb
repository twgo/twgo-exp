require 'github_api'
require 'net/http'

class ExpsWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options retry: false

  def perform(*args)
    p 'ExpsWorker start'

    exp = Exp.find_by(status: 'added')

    if exp
      Round.find_by(jid: exp.upstream).down_streams.create(branch: exp.branch)
      create_exp_on_github exp.upstream_info, exp.repo, exp.branch, exp.content, exp.sha

      exp.update(status: 'working')
    end
    
    p 'ExpsWorker OK'
  end

  private

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

  def create_branch repo, temp_branch, sha
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    github_client.create_ref "twgo/#{repo}", "heads/#{temp_branch}", sha
  end

  def delete_branch repo, temp_branch
    github_client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    github_client.delete_ref "twgo/#{repo}", "heads/#{temp_branch}"
  end
end
