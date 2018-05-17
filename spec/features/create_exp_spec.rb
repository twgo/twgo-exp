require 'rails_helper'

describe "create exp", type: :feature do
  before :each do
    Round.create(jid: "siann1-hak8_boo5-hing5/44")
    allow_any_instance_of(GithubsController).to receive(:create_exp_on_github)
  end

  it "create exp successful" do
    visit '/githubs?utf8=%E2%9C%93&repo=gi2-gian5_boo5-hing5&branch=free-syllable-tw01test-%E4%BB%9D%E8%AA%9E%E8%80%85&sha=a4a9c7d698028fd01e4582c635210e04b3af64e3&downstream=free-syllable-tw01test-%E4%BB%9D%E8%AA%9E%E8%80%85ooooa4a9c7d698028fd01e4582c635210e04b3af64e3&upstream=siann1-hak8_boo5-hing5%2F44'
    click_button 'COMMIT & RUN'
    expect(page).to have_content '實驗已建立!'
  end
end
