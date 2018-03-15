class StaticController < ApplicationController
  def download
    send_file "#{Rails.root}/public/results/exp-1-df3jflkfsd.tar.gz" , type: 'text/plain; charset=utf-8'
  end
end
