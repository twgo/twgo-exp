require 'json'
require 'open-uri'

class RoundsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :login_jenkins, only: [:index, :refresh]

  def index
    unuseful_branch = Rails.configuration.my_hidden_branches
    @experiments = @repos
    @rounds = Round.order(id: :desc)
    @experiments.each do |e|
      instance_variable_set(
        "@ci_data_#{e.gsub('-', '_')}",
        Round.where(repo: e).where.not(branch: unuseful_branch).order(id: :desc)
      )
    end
  end

  def update
    round = Round.find(params[:id])
    round.update_attributes(round_params)
    redirect_to rounds_path, notice: "標籤已建立!"
  end

  def refresh
    JenkinsWorker.perform_async
    redirect_to rounds_path
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

  private

  def ci_answer repo, expid
    %x(ssh -t ci@10.32.0.120 "docker run localhost:5000/#{repo}:#{expid} cat /usr/local/kaldi/egs/taiwanese/s5c/exp/tri4/decode_train_dev/scoring/text.filt > exp/text.filt;exit")
    %x(ssh -t exp@10.32.0.124 "scp ci@10.32.0.120:exp/text.filt #{Rails.root}/public/results")
  end

  def ci_best repo, expid
    best_result = %x(ssh -t ci@10.32.0.120 "curl -s 'https://raw.githubusercontent.com/leo424y/f/master/twgo_best.sh' | docker run -i localhost:5000/#{params[:repo]}:#{params[:expid]}")
    %x(echo "#{best_result}" > #{Rails.root}/public/results/best.txt)
  end

  def login_jenkins
    @jenkins = JenkinsApi::Client.new(
      server_ip: ENV['CI_HOST'],
      server_port: '80',
      username: ENV['CI_ID'],
      password: ENV['CI_PWD'])

    @repos = @jenkins.job.list_all
  end

  def build_counts(exp_name)
    @jenkins.job.get_current_build_number(exp_name)
  end

  def round_params
    params.require(:round).permit(:label)
  end
end
