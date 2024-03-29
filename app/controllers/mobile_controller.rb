class MobileController < ApplicationController
  unloadable

  before_filter :require_login

  def index
    @overdue_issues = get_overdue_issues
    @due_today_issues = get_due_today_issues
    @near_due_issues = get_near_due_issues
    @doing_issues = get_doing_issues
    @new_issues = get_new_issues
  end

  def issues_list
    case params[:list_mode]
    when 'overdue'
      @title = 'Overdue'
      @issues = get_overdue_issues
    when 'due_today'
      @title = 'Due today'
      @issues = get_due_today_issues
    when 'near_due'
      @title = 'Due in 7 days'
      @issues = get_near_due_issues
    when 'doing'
      @title = 'Doing'
      @issues = get_doing_issues
    when 'new'
      @title = 'New'
      @issues = get_new_issues
    else
      @title = 'My issues'
      @issues = get_my_issues
    end
  end

  def issue
    issue_id = params[:issue_id]
    begin
      @issue = Issue.find(issue_id)
      @title = "#{@issue.tracker.name}  ##{@issue.id} (#{@issue.status})"
    rescue RecordNotFound  
      redirect_to :action => index && return
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

  def get_near_due_issues
    Issue.visible.open.find(:all,
      :conditions => [
        "assigned_to_id = ? and ? < due_date and due_date <= ?",
        User.current.id,
        Date.today,
        Date.today + 7
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

  def get_doing_issues
    default_issue_status = IssueStatus.find_by_is_default(true)
    Issue.visible.open.find(:all,
      :conditions => ["assigned_to_id = ? and #{IssueStatus.table_name}.id <> ?", User.current.id, default_issue_status],
      :include => [:status, :project, :tracker, :priority],
      :order => "#{Issue.table_name}.updated_on desc")
  end

  def get_new_issues
    default_issue_status = IssueStatus.find_by_is_default(true)
    Issue.visible.open.find(:all,
      :conditions => ["assigned_to_id = ? and #{IssueStatus.table_name}.id = ?", User.current.id, default_issue_status],
      :include => [:status, :project, :tracker, :priority],
      :order => "#{Issue.table_name}.updated_on desc")
  end

end
