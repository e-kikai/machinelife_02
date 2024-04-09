class Admin::MainController < Admin::ApplicationController
  def index
    @infos = Info.where(target: :member).order(info_date: :desc).limit(10)
    @urikais = Urikai.includes(:company).where(end_date: nil).order(created_at: :desc)
    @miniblogs = Miniblog.includes(:user).where(target: :machine).order(created_at: :desc).limit(20)

    @miniblog_form = Admin::MiniblogForm.new({ target: :machine })
  end
end
