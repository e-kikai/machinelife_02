columns = %w[id top_image]

CSV.generate do |row|
  row << columns

  @machines.pluck(columns).each { |ma| row << ma }
  @old_machines.pluck(columns).each { |ma| row << ma }
end
