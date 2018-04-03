require 'json'
require 'open-uri'

class RoundsController < ApplicationController
  EXPERIMENTS = ['siann1-hak8_boo5-hing5', 'gi2-gian5_boo5-hing5']

  HOST_URL = 'http://10.32.0.120/job'

  def index
    @experiments = EXPERIMENTS
    @rounds = Round.where.not(rate: 0).order(id: :desc)
    @experiments.each do |e|
      instance_variable_set("@ci_data_#{e.gsub('-', '_')}", Round.where("jid like ?", "#{e}%").where.not(rate: 0).order(id: :desc) )
    end
  end

  def update
    round = Round.find(params[:id])
    round.update_attributes(round_params)
    redirect_to rounds_path
  end

  def refresh
    EXPERIMENTS.each do |exp_name|
      if Round.count != build_counts(exp_name)
        result = ci_success_exp_git(exp_name)
        new_round = []
        result.each{|r| new_round << {jid: r[:jid], cid: r[:cid], did: r[:did], info: r[:info], rate: r[:rate]}}
        new_round.each{|n| Round.find_or_initialize_by(jid: n[:jid]).update!(n)}
      end
    end
    redirect_to rounds_path
  end

  private

  def build_counts(exp_name)
    JSON.parse(open("#{ENV['CI_HOST']}/#{exp_name}/api/json",
      http_basic_authentication: ['ci','ci' ]) {|f| f.read })['builds'].first['number']
  end

  def ci_success_exp_git(exp_name)
    all_build_counts = build_counts(exp_name)

    all_exp_detail=[]
    (1..all_build_counts).each{|x| all_exp_detail  << open("#{ENV['CI_HOST']}/#{exp_name}/#{x}/api/json", http_basic_authentication: ['ci','ci' ]) {|f| f.read } }

    success_exp_detail = []
    (1..all_build_counts).each do |x|
      r=JSON.parse(all_exp_detail[x-1])
      success_exp_detail << r if r['result']=='SUCCESS'
    end

    success_exp_number=[]
    (0..success_exp_detail.count-1).each {|x| success_exp_number << success_exp_detail[x]['number']}

    success_exp=[]
    (0..success_exp_detail.count-1).each do |x|
      success_exp_detail_number = success_exp_detail[x]['number']
      commit_hash = success_exp_detail[x]['actions'].find {|h| h.has_key? 'lastBuiltRevision' }['lastBuiltRevision']['branch']
      success_exp << {
        jid: "#{exp_name}/#{success_exp_detail_number}",
        cid: commit_hash,
        info: commit_message(exp_name, commit_hash),
        did: docker_id(exp_name, success_exp_detail_number),
        rate: exp_rate(exp_name, success_exp_detail_number),
      }
    end

    success_exp
  end

  def docker_id(exp_name, id)
    a = open("#{HOST_URL}/#{exp_name}/#{id}/docker/", http_basic_authentication: ['ci','ci' ]) {|f| f.read } .split

    a[(a.index('Id:</b>')+1)]
  end

  def commit_message(exp_name, commit_hash)
    url = "https://api.github.com/repos/twgo/#{exp_name}/commits/#{commit_hash[0]['SHA1']}"
    JSON.parse(open(url) {|f| f.read })["commit"]["message"]
  end

  def exp_rate(exp_name, id)
    result = open("#{HOST_URL}/#{exp_name}/#{id}/consoleText", http_basic_authentication: ['ci','ci' ]) {|f| f.read }
    result.split("\n").select{ |i| i[/%WER/i] }.map(&:split).map{|x| x[1]}.min || 0
  end

  def round_params
    params.require(:round).permit(:label)
  end
end
