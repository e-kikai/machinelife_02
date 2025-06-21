class MakersController < ApplicationController
  def index
    @key  = Maker::KANA_GROUP_REGEX.key?(params[:key]) ? params[:key] : Maker::KANA_GROUP_REGEX.keys.first
    regex = Maker::KANA_GROUP_REGEX[@key]

    @makers =
      Machine
        .sales.left_joins(:maker_m)
        .where.not(maker2: ["", "xxx", nil]).where("COALESCE(makers.maker_kana, machines.maker2) ~ ?", regex)
        .group("COALESCE(makers.maker_master, machines.maker2)", "COALESCE(makers.maker_kana, machines.maker2)")
        .count
        .sort_by { |k, _| [(k[1].match?(/^[0-9A-Za-z]/) ? 1 : 0), k[1].to_s] }.to_h { |k, v| [k[0], v] }

    @maker_images =
      Machine
        .select(
          "DISTINCT ON (COALESCE(makers.maker_master, machines.maker2)) machines.*, " \
          "COALESCE(makers.maker_master, machines.maker2) AS maker_name"
        )
        .left_joins(:maker_m)
        .with_images.where.not(maker2: ["", "xxx", nil]).where("COALESCE(makers.maker_kana, machines.maker2) ~ ?", regex)
        .order(Arel.sql("COALESCE(makers.maker_master, machines.maker2) ASC"), id: :desc)
        .to_h { |m| [m.maker_name, m.top_image_thumb] }
  end
end
