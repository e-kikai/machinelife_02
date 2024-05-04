class Admin::MiniblogsController < Admin::ApplicationController
  def create
    @miniblog_form = Admin::MiniblogForm.new(miniblog_params, user: current_user)

    if @miniblog_form.save
      flash.now[:notice] = "書き込みました。"
    else
      flash.now[:danger] = '書き込みに失敗しました'
    end

    render "_form", { target: :catalog }
  end

  private

  def miniblog_params
    params.require(:admin_miniblog_form).permit(:target, :contents)
  end
end
