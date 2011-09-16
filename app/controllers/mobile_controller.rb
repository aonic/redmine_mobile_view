class MobileController < ApplicationController
  unloadable

  before_filter :require_login

  def index
    @overdue_issues = get_overdue_issues
    @due_today_issues = get_due_today_issues
  end

  def issues_list
    case params[:list_mode]
    when 'overdue'
      @title = 'Overdue issues'
      @issues = get_overdue_issues
    else
      @title = 'My issues'
      @issues = get_my_issues
    end
  end

  private
  def get_my_issues
    Issue.visible.open.find(:all,
      :conditions => [
        "assigned_to_id = ?",
        User.current.id,
      ],
      :include => [:status, :project, :tracker, :priority],
      :order => "due_date")
  end

  def get_overdue_issues
    Issue.visible.open.find(:all,
      :conditions => [
        "assigned_to_id = ? and due_date < ?",
        User.current.id,
        Date.today,
      ],
      :include => [:status, :project, :tracker, :priority],
      :order => "due_date")
  end

  def get_due_today_issues
    Issue.visible.open.find(:all,
      :conditions => [
        "assigned_to_id = ? and due_date = ?",
        User.current.id,
        Date.today,
      ],
      :include => [:status, :project, :tracker, :priority],
      :order => "due_date")
  end
end
