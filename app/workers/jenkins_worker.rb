class JenkinsWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options retry: false

  def perform(*args)
    p 'start'
    refresh
    p 'OK'
  end

  def refresh
    login_jenkins
    @github_client = Octokit::Client.new(login: ENV['GITHUB_ID'] , password: ENV['GITHUB_SECRET'])
    @repos.each do |exp_name|
      if Round.count != build_counts(exp_name)
        result = ci_success_exp_git(exp_name)
        new_round = []
        result.each { |r| new_round << {
          jid: r[:jid],
          cid: r[:cid],
          did: r[:did],
          info: r[:info],
          rate: r[:rate],
          rate2: r[:rate2],
          repo: r[:repo],
          expid: r[:expid],
          sha1: r[:sha1],
          branch: (r[:branch].start_with?('_') ? r[:branch][1..-1] : r[:branch])
          }
        }
        new_round.each{|n| Round.find_or_initialize_by(jid: n[:jid]).update!(n)}
      end
    end
  end

  private

  def build_counts(exp_name)
    @jenkins.job.get_current_build_number(exp_name)
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
      to_commit_hash = success_exp_detail[x]['actions'].find {|h| h.has_key? 'lastBuiltRevision' }
      if to_commit_hash
        commit_hash = to_commit_hash['lastBuiltRevision']['branch']
        branch = commit_hash[0]['name'].split('/').last
        if branch != 'master'
          result = success_exp_detail[x]['result']
          success_exp << {
            jid: "#{exp_name}/#{success_exp_detail_number}",
            cid: commit_hash,
            info: commit_message(exp_name, commit_hash),
            did: docker_id(exp_name, success_exp_detail_number, result),
            rate: exp_rate(exp_name, success_exp_detail_number, result, 'rate'),
            rate2: exp_rate(exp_name, success_exp_detail_number, result, 'rate2'),
            repo: exp_name,
            expid: success_exp_detail_number,
            sha1: commit_hash[0]['SHA1'],
            branch: branch,
          }
        end
      end
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
    begin
      sha = commit_hash[0]['SHA1']
      if (sha !='2e2d1ab5c04cf542f94035ceadc68787878bba0d') || (sha !='b5698cf3056475a40797e98381c39389b584035d')
        @github_client.commit("twgo/#{exp_name}", sha)
      else
        ''
      end
    rescue
      ''
    end
  end

  def exp_rate(exp_name, id, status, rate_type)
    if status=='FAILURE'
      999
    elsif status=='SUCCESS'
      result = open("http://#{ENV['CI_HOST']}/job/#{exp_name}/#{id}/consoleText", http_basic_authentication: [ ENV['CI_ID'], ENV['CI_PWD'] ]) {|f| f.read }
      (rate_type=='rate') ? (tri_no_si result) : (tri_si result)
    else
      888
    end
  end

  def login_jenkins
    @jenkins = JenkinsApi::Client.new(
      server_ip: ENV['CI_HOST'],
      server_port: '80',
      username: ENV['CI_ID'],
      password: ENV['CI_PWD'])

    @repos = @jenkins.job.list_all
  end

  def tri_no_si result
    result.split("\n").select{ |i| i[/%WER/i] }.map(&:split).map{|x| x[1]}[-2] || 0
  end

  def tri_si result
    result.split("\n").select{ |i| i[/%WER/i] }.map(&:split).map{|x| x[1]}[-1] || 0
  end
end
