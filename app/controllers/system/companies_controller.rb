class System::CompaniesController < System::ApplicationController
  include Exports

  before_action :set_company, only: %i[edit update destroy login]

  def index
    @groups = Group.includes(:companies, :parent).where(companies: { deleted_at: nil }).order(:parent_id, :id, "companies.id")

    respond_to do |format|
      format.html
      format.csv do
        @companies         = Company.includes(:group, :parent, :parent_company).where(deleted_at: nil).order(:id)
        @counts_by_company = Machine.sales.group(:company_id).count
        export_csv "companies.csv"
      end
    end
  end

  def pdf
    @companies = Company.order(:id)

    respond_to do |format|
      format.html
      format.pdf
    end
  end

  def new
    @company_form = System::CompanyForm.new
  end

  def edit
    @company_form = System::CompanyForm.new(company: @company)
  end

  def create
    @company_form = System::CompanyForm.new(company_params)

    if @company_form.save
      redirect_to "/system/companies", notice: "会社情報を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @company_form = System::CompanyForm.new(company_params, company: @company)

    if @company_form.save
      redirect_to "/system/companies", notice: "会社情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.soft_delete

    redirect_to "/system/companies", status: :see_other, notice: "#{@company.id} : #{@company.company} の会社情報を削除しました。"
  end

  def login
    session[:company_id] = @company.id

    redirect_to "/admin/", notice: "#{@company.company}で代理ログインしました"
  end

  private

  def set_company
    @company = Company.where(deleted_at: nil).find(params[:id])
  end

  def company_params
    params.require(:system_company_form)
      .permit(:company_name, :company_kana, :representative, :zip, :addr1, :addr2, :addr3, :tel, :fax, :mail, :website, :group_id, :rank)
  end
end
