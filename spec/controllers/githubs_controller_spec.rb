require 'rails_helper'
require 'octokit'
RSpec.describe GithubsController, type: :controller do
  before do
    Round.create(jid: 'siann1-hak8_boo5-hing5/1')
    @params = {repo: 'gi2-gian5_boo5-hing5', sha: 'master'}
    @params_github = {github_code: {
      repo: 'pian7sik4',
      branch: 'master',
      content: 'This file is only for twgo-exp testing!',
      upstream: 'siann1-hak8_boo5-hing5/1',
      upstream_info: 'jid_info of upstream',
      }}
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: @params
      expect(response).to be_success
    end

    it "returns repo's Dockerfile code" do
      my_object = GithubsController.new
      origin_code = my_object.send(:get_dockerfile, @params[:repo], @params[:sha])
      expect(origin_code).to start_with("FROM")
    end

    it "returns repo's branch list" do
      my_object = GithubsController.new
      repo_list = my_object.send(:get_branches, 'twgo/gi2-gian5_boo5-hing5' )
      expect(repo_list.pluck(:down_name).include? 'master').to be true
    end
  end

  describe "GET #update" do
    it "update github code with upstream, and redirect to rounds_path" do
      patch :update, params: @params_github
      expect(response).to redirect_to(githubs_path(select_down: 'yes'))
    end
  end
end
