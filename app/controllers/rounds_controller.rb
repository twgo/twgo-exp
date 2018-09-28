require 'json'
require 'open-uri'

class RoundsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :login_jenkins, only: [:index, :refresh, :run_next]

  def index
    unuseful_branch = Rails.configuration.my_hidden_branches
    @experiments = @repos
    @rounds = Round.order(id: :desc)
    @experiments.each do |e|
      instance_variable_set(
        "@ci_data_#{e.gsub('-', '_')}",
        Round.where(repo: e).where.not(branch: unuseful_branch, jid: 'gi2-gian5_boo5-hing5/60').order(id: :desc)
      )
    end
  end

  def run_next
    @repos.each do |r|
      # 檢查每個repo有沒有閒置未做的實驗，執行
      rounds = Round.where(repo: r)
      no_running = (rounds.where.not(status: 'running') && rounds.where(status: 'added'))
      all_done = (rounds.find_by(status: 'running') != nil) && (rounds.find_by(status: 'running').rate != nil)

      if all_done
        rounds.update_all(status: 'finished')
        ExpsWorker.perform_async(r)
      elsif no_running
        ExpsWorker.perform_async(r)
      end
    end
  end

  def update
    round = Round.find(params[:id])
    round.update_attributes(round_params)
  end

  def refresh
    JenkinsWorker.perform_async
    redirect_to rounds_path, notice: "實驗刷新中，請稍待一陣子!"
  end

  def answer
    ci_answer params[:repo], params[:expid]

    send_file(
      "#{Rails.root}/public/results/text.filt",
      filename: "#{params[:repo]}_#{params[:expid]}_text.filt",
      type: "text/plain"
    )
  end

  def best
    ci_best params[:repo], params[:expid]

    send_file(
      "#{Rails.root}/public/results/best.txt",
      filename: "#{params[:repo]}_#{params[:expid]}_best.txt",
      type: "text/plain"
    )
  end

  def audio
    send_file(
      "#{Rails.root}/public/results/TW01M_TEST.gz",
      filename: "TW01M_TEST.gz",
      type: "text/plain"
    )
  end

  private

  def ci_answer repo, expid
    %x(echo `ssh -tt ci@10.32.0.120 "docker run dockerhub.iis.sinica.edu.tw/#{repo.downcase}:#{expid} cat /usr/local/kaldi/egs/taiwanese/s5c/exp/tri4/decode_train_dev/scoring/text.filt | cat"` > ./public/results/text.filt)
  end

  def ci_best repo, expid
    %x(echo `ssh -tt ci@10.32.0.120 "curl -s 'https://raw.githubusercontent.com/leo424y/f/master/twgo_best.sh' | docker run -i dockerhub.iis.sinica.edu.tw/#{repo.downcase}:#{expid}"` > ./public/results/best.txt)
  end

  def login_jenkins
    @jenkins = JenkinsApi::Client.new(
      server_ip: ENV['CI_HOST'],
      server_port: '80',
      username: ENV['CI_ID'],
      password: ENV['CI_PWD'])

    @repos = @jenkins.job.list_all - ['zh-min-nan']
  end

  def build_counts(exp_name)
    @jenkins.job.get_current_build_number(exp_name)
  end

  def round_params
    params.require(:round).permit(:label)
  end
end
