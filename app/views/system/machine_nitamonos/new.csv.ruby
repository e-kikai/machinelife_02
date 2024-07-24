columns = %w[id top_image]

CSV.generate do |row|
  row << columns

  @machines.pluck(columns).each do |ma|
    # row << [ma.id, (ma.machine_nitamonos.blank? ? ma&.top_image : nil)]
    row << ma
  end
end
