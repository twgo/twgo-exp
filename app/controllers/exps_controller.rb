require 'json'
require 'open-uri'

class ExpsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    Exp.where(status: 'working').update_all(status: 'finished')
    ExpsWorker.perform_async if Exp.find_by(status: 'added')
  end
end
