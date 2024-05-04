class Admin::CompaniesController < Admin::ApplicationController
  def edit
    @company_form = Admin::CompanyForm.new(company: current_company)
  end

  def update
    @company_form = Admin::CompanyForm.new(company_params, company: current_company)

    if @company_form.save
      redirect_to "/admin/", notice: "会社情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:admin_company_form)
      .permit(
        :officer, :contact_tel, :contact_fax, :contact_mail,
        :info_pr, :info_comment, :info_access_train, :info_access_car, :info_opening, :info_holiday, :info_license,
        :top_image, :top_image_delete, images: [], imgs_delete: [], images_delete: [], images_cancel: [], offices: [:name, :zip, :addr1, :addr2, :addr3]
      )
  end
end
