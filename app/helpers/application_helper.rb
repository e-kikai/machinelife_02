module ApplicationHelper
  include Pagy::Frontend

  def default_meta_tags
    {
      site: "マシンライフ",
      reverse: true,
      separator: "|",
      charset: "utf-8",
      'theme-color': "#27367B",
      viewport: "width=device-width, initial-scale=1",
      icon: [
        { href: image_url('design/favicon.ico') }
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: :canonical,
        image: image_url('header/logo_machinelife.png'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary',
        site: '@zenkiren'
      },
      'turbo-prefetch': false,
      robots: Rails.env.production? && request.path_info !~ /admin|system|catalog|playground/ ? :index : :noindex
    }
  end

  def daihou_meta_tags
    {
      site: "大宝機械株式会社",
      reverse: true,
      separator: "|",
      charset: "utf-8",
      'theme-color': "#003c64",
      viewport: "width=device-width, initial-scale=1",
      icon: [
        { href: image_url('daihou/favicons/favicon.ico') }
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: :canonical,
        image: image_url('daihou/daihou_logo.png'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary',
        site: '@zenkiren'
      },
      'turbo-prefetch': false,
      robots: Rails.env.production? ? :index : :noindex
    }
  end

  def zenkiren_meta_tags
    {
      site: "全機連 - 全日本機械業連合会",
      reverse: true,
      separator: "|",
      charset: "utf-8",
      'theme-color': "#003c64",
      viewport: "width=device-width, initial-scale=1",
      icon: [
        { href: image_url('zenkiren/favicon.ico') }
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: :canonical,
        image: image_url('zenkiren/zenkiren_logo.png'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary',
        site: '@zenkiren'
      },
      'turbo-prefetch': false,
      robots: Rails.env.production? ? :index : :noindex
    }
  end

  ### Material icon ###
  def mi(symbol, cls = "")
    content_tag(:i, symbol, class: "material-icons #{cls}", 'aria-hidden': true)
  end

  ### ログインユーザ情報取得 ###
  def user_signed_in
    session[:user_id].present?
  end

  def current_user_id
    session[:user_id] || nil
  end

  def current_user
    User.find(current_user_id)
  end

  def current_company_id
    session[:company_id] || nil
  end

  def current_company
    current_company_id.present? ? Company.find(current_company_id) : nil
  end
end
