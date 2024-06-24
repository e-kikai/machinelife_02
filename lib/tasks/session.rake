namespace :session do
  task sweep: :environment do
    puts 'sweep old sessions.'
    Session.sweep
    puts 'sweep task finished.'
  end
end
