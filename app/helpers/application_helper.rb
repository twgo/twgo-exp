module ApplicationHelper
  def has_up(repo)
    repo_with_upstream = ['gi2-gian5_boo5-hing5']
    if repo_with_upstream.include? repo
      'y'
    else
      'n'
    end
  end
end
