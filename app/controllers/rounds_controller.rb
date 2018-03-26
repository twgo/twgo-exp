require 'json'
require 'open-uri'

class RoundsController < ApplicationController
  def index
    @rounds = Round.all
  end

  def refresh
    ['siann1-hak8_boo5-hing5', 'gi2-gian5_boo5-hing5'].each do |exp_name|
      if Round.count != build_counts(exp_name)
        result = ci_success_exp_git(exp_name)
        new_round = []
        result.each{|r| new_round << {jid: r[:jid], cid: r[:cid], did: r[:did], info: 'info', label: 'label', rate: '10.01'}}
        new_round.each{|n| Round.find_or_initialize_by(jid: n[:jid]).update!(n)}
      end
    end
    redirect_to rounds_path
  end

  def build_counts(exp_name)
    JSON.parse(open("http://10.32.0.120/job/#{exp_name}/api/json",
      http_basic_authentication: ['ci','ci' ]) {|f| f.read })['builds'].first['number']
  end

  def ci_success_exp_git(exp_name)
    all_build_counts = build_counts(exp_name)

    all_exp_detail=[]
    (1..all_build_counts).each{|x| all_exp_detail  << open("http://10.32.0.120/job/#{exp_name}/#{x}/api/json", http_basic_authentication: ['ci','ci' ]) {|f| f.read } }

    success_exp_detail = []
    (1..all_build_counts).each do |x|
      r=JSON.parse(all_exp_detail[x-1])
      success_exp_detail << r if r['result']=='SUCCESS'
    end

    success_exp_number=[]
    (0..success_exp_detail.count-1).each {|x| success_exp_number << success_exp_detail[x]['number']}

    success_exp=[]
    (0..success_exp_detail.count-1).each {|x| success_exp << {
      jid: "#{exp_name}/#{success_exp_detail[x]['number']}",
      cid: success_exp_detail[x]['actions'].find {|h| h.has_key? 'lastBuiltRevision' }['lastBuiltRevision']['branch'],
      did: docker_id(exp_name, success_exp_detail[x]['number'])}
    }

    success_exp
  end

  def docker_id(exp_name, id)
    a = open("http://10.32.0.120/job/#{exp_name}/#{id}/docker/", http_basic_authentication: ['ci','ci' ]) {|f| f.read } .split

    a[(a.index('Id:</b>')+1)]
  end
end
