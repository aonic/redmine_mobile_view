class MobileController < ApplicationController
  unloadable

  before_filter :require_login

  def index
    @overdue_issues = Issue.visible.open.find(:all,
      :conditions => [
        "(assigned_to_id = ? or assigned_to_id is null) and due_date < ?",
        User.current.id,
        Date.today,
      ],
      :include => [:status, :project, :tracker, :priority],
      :order => "due_date")
  end
end
