require 'json'
require 'open-uri'

class RoundsController < ApplicationController
  def download
    send_file "#{Rails.root}/public/results/exp-1-df3jflkfsd.tar.gz" , type: 'text/plain; charset=utf-8'
  end

  def index
    update_round
    @rounds = Round.all
  end

  def update_round
    if has_new_round?
      result = ci_success_exp_git
      new_round = {jid: result.last[:jid], cid: result.last[:cid], did: 1, info: 'info', label: 'label', rate: '10.01'}
      Round.create!(new_round)
    end
  end

  def has_new_round?
    Round.count != build_counts
  end

  def exp_name
    'siann1-hak8_boo5-hing5'
  end

  def all_exp_hash
    JSON.parse(open("http://10.32.0.120/job/#{exp_name}/api/json", http_basic_authentication: ['ci','ci' ]) {|f| f.read })
  end

  def build_counts
    all_exp_hash['builds'].first['number']
  end

  def ci_success_exp_git
    all_exp_detail=[]
    (1..build_counts).each{|x| all_exp_detail  << open("http://10.32.0.120/job/#{exp_name}/#{x}/api/json", http_basic_authentication: ['ci','ci' ]) {|f| f.read } }
    all_exp_detail

    success_exp_detail = []
    (1..build_counts).each do |x|
      r=JSON.parse(all_exp_detail[x-1])
      success_exp_detail << r if r['result']=='SUCCESS'
    end
    success_exp_detail

    success_exp_number=[]
    (0..success_exp_detail.count-1).each {|x| success_exp_number << success_exp_detail[x]['number']}
    success_exp_number

    success_exp=[]
    (0..success_exp_detail.count-1).each {|x| success_exp << {jid: success_exp_detail[x]['number'], cid: success_exp_detail[x]['actions'].find {|h| h.has_key? 'lastBuiltRevision' }['lastBuiltRevision']['branch'] } }
    success_exp
  end
end
