module ApplicationHelper
  def has_up repo
    repo_with_upstream = ['gi2-gian5_boo5-hing5', 'DNN-test']
    if repo_with_upstream.include? repo
      'y'
    else
      'n'
    end
  end

  def show_rate_status rate
    case rate
    when 999.0
      '失敗'
    when 0.0
      '無印結果'
    when 888.0
      '正在跑'
    else
      rate
    end
  end
end
