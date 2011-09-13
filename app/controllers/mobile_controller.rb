class MobileController < ApplicationController
  unloadable

  before_filter :require_login

  def index
    @overdue_issues = get_overdue_issues
  end

  def issues_list
    case params[:list_mode]
    when 'overdue'
      @issues = get_overdue_issues
    else
      @issues = get_my_issues
    end
  end

  private
  def get_my_issues
    @overdue_issues = Issue.visible.open.find(:all,
      :conditions => [
        "assigned_to_id = ?",
        User.current.id,
      ],
      :include => [:status, :project, :tracker, :priority],
      :order => "due_date")
  end

  def get_overdue_issues
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
