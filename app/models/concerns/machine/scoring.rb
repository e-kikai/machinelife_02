module Machine::Scoring
  extend ActiveSupport::Concern

  SCORE_WEIGHTS = {
    access: 10,
    contact: 200,
    image: 100,
    youtube: 200,
    catalog: 40,
    commission: 60,
    capacity: 10,
    negotiation: -200
  }.freeze

  SCORING_DAY = Time.current.ago(1.week)

  included do
    # scope :with_access_score, lambda {
    #   joins(<<~SQL.squish)
    #     LEFT JOIN (
    #       SELECT
    #         machine_id,
    #         COUNT(*) * #{SCORE_WEIGHTS[:access]}
    #       FROM detail_logs
    #       WHERE created_at >= '#{SCORING_DAY.to_fs(:db)}'
    #       GROUP BY machine_id
    #     ) AS access_scores ON access_scores.machine_id = machines.id
    #   SQL
    # }

    # scope :with_total_score, lambda {
    #   with_access_score.with_content_score.select(
    #     'machines.*, COALESCE(access_scores.access_score, 0) + COALESCE(content_scores.content_score, 0) AS total_score'
    #   )
    # }

    # scope :order_by_access_score, lambda { |dir|
    #   with_access_score.order("access_scores.access_score #{dir || :desc}")
    # }

    scope :order_by_content_score, lambda { |dir|
      order(Arel.sql(<<~SQL.squish))
        (CASE WHEN ((machines.top_img IS NOT NULL AND machines.top_img <> '') OR (machines.top_image IS NOT NULL AND machines.top_image <> '')) THEN #{SCORE_WEIGHTS[:image]} ELSE 0 END +
          CASE WHEN machines.youtube IS NOT NULL AND machines.youtube != '' AND machines.youtube != 'http://youtu.be/' THEN #{SCORE_WEIGHTS[:youtube]} ELSE 0 END +
          CASE WHEN machines.catalog_id IS NOT NULL THEN #{SCORE_WEIGHTS[:catalog]} ELSE 0 END +
          CASE WHEN machines.commission = 1 THEN #{SCORE_WEIGHTS[:commission]} ELSE 0 END +
          CASE WHEN machines.view_option = 1 THEN #{SCORE_WEIGHTS[:negotiation]} ELSE 0 END +
          CASE WHEN machines.maker2 != '' THEN #{SCORE_WEIGHTS[:capacity]} ELSE 0 END +
          CASE WHEN machines.year != '' THEN #{SCORE_WEIGHTS[:capacity]} ELSE 0 END +
          CASE WHEN machines.capacity IS NOT NULL THEN #{SCORE_WEIGHTS[:capacity]} ELSE 0 END +
          CASE WHEN machines.addr1 != '' THEN #{SCORE_WEIGHTS[:capacity]} ELSE 0 END
        ) #{dir}
      SQL
    }

    # scope :order_by_total_score, lambda { |dir|
    #   with_total_score.order("total_score #{dir || :desc}")
    # }
  end
end
