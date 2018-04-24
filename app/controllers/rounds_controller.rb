require 'json'
require 'open-uri'

class RoundsController < ApplicationController
  EXPERIMENTS = ['siann1-hak8_boo5-hing5', 'gi2-gian5_boo5-hing5']

  def index
    @experiments = EXPERIMENTS
    @rounds = Round.order(id: :desc)
    @experiments.each do |e|
      instance_variable_set("@ci_data_#{e.gsub('-', '_')}",
      Round.where(repo: e).order(id: :desc) )
    end
  end

  def update
    round = Round.find(params[:id])
    round.update_attributes(round_params)
    redirect_to rounds_path
  end

  def refresh
    @client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    EXPERIMENTS.each do |exp_name|
      if Round.count != build_counts(exp_name)
        result = ci_success_exp_git(exp_name)
        new_round = []
        result.each { |r| new_round << {
          jid: r[:jid],
          cid: r[:cid],
          did: r[:did],
          info: r[:info],
          rate: r[:rate],
          repo: r[:repo],
          expid: r[:expid],
          sha1: r[:sha1],
          branch: r[:branch],
          }
        }
        new_round.each{|n| Round.find_or_initialize_by(jid: n[:jid]).update!(n)}
      end
    end
    redirect_to rounds_path
  end

  private

  def build_counts(exp_name)
    JSON.parse(open("http://#{ENV['CI_HOST']}/job/#{exp_name}/api/json",
      http_basic_authentication: [ ENV['CI_ID'], ENV['CI_PWD'] ]) {|f| f.read })['builds'].first['number']
  end

  def ci_success_exp_git(exp_name)
    github = Github.new basic_auth: "#{ENV['GITHUB_ID']}:#{ENV['GITHUB_SECRET']}"
    github.auth.create scopes: ['repo'], note: 'admin script' unless github.auth

    all_build_counts = build_counts(exp_name)

    all_exp_detail=[]
    skip_exp=[]
    (1..all_build_counts).each do |x|
      uri = URI.parse("http://#{ENV['CI_HOST']}/job/#{exp_name}/#{x}/api/json")
      get = Net::HTTP::Get.new(uri.path)
      get.basic_auth ENV['CI_ID'], ENV['CI_PWD']
      Net::HTTP.new(uri.host, uri.port).start {|http|
        http.request(get) {|response|
          if response.code == "200"
            detail = open(uri, http_basic_authentication: [ ENV['CI_ID'], ENV['CI_PWD'] ]) {|f| f.read }
            all_exp_detail << detail
          else
            skip_exp << x
          end
        }
      }
    end

    success_exp_detail = []
    all_exp_detail.each do |x|
      if skip_exp.exclude? (JSON.parse(x)['number'])
        r=JSON.parse(x)
        success_exp_detail << r
      end
    end

    success_exp_number=[]
    (0..success_exp_detail.count-1).each {|x| success_exp_number << success_exp_detail[x]['number']}

    success_exp=[]
    (0..success_exp_detail.count-1).each do |x|
      success_exp_detail_number = success_exp_detail[x]['number']
      commit_hash = success_exp_detail[x]['actions'].find {|h| h.has_key? 'lastBuiltRevision' }['lastBuiltRevision']['branch']
      result = success_exp_detail[x]['result']
      success_exp << {
        jid: "#{exp_name}/#{success_exp_detail_number}",
        cid: commit_hash,
        info: commit_message(exp_name, commit_hash),
        did: docker_id(exp_name, success_exp_detail_number, result),
        rate: exp_rate(exp_name, success_exp_detail_number, result),
        repo: exp_name,
        expid: success_exp_detail_number,
        sha1: commit_hash[0]['SHA1'],
        branch: commit_hash[0]['name'].split('/').last,
      }
    end

    success_exp
  end

  def docker_id(exp_name, id, result)
    if result=='SUCCESS'
      a = open("http://#{ENV['CI_HOST']}/job/#{exp_name}/#{id}/docker/", http_basic_authentication: [ ENV['CI_ID'], ENV['CI_PWD'] ]) {|f| f.read } .split
      a[(a.index('Id:</b>')+1)]
    else
      'FAILURE'
    end
  end

  def commit_message(exp_name, commit_hash)
    @client.commit("twgo/#{exp_name}", commit_hash[0]['SHA1'])
  end

  def exp_rate(exp_name, id, status)
    if status=='FAILURE'
      999
    else
      result = open("http://#{ENV['CI_HOST']}/job/#{exp_name}/#{id}/consoleText", http_basic_authentication: [ ENV['CI_ID'], ENV['CI_PWD'] ]) {|f| f.read }
      result.split("\n").select{ |i| i[/%WER/i] }.map(&:split).map{|x| x[1]}.min || 0
    end
  end

  def round_params
    params.require(:round).permit(:label)
  end
end
