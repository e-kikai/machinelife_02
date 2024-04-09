require 'pagy/extras/bootstrap'
require 'pagy/extras/i18n'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items]      = 30
Pagy::DEFAULT[:size]       = [1, 5, 5, 1]
Pagy::DEFAULT[:page_param] = :page
Pagy::DEFAULT[:overflow]   = :last_page
