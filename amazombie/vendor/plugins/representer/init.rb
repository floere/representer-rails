require 'presenters'
require 'presenters/base'
require 'presenters/active_record'
require 'presenters/collection'

require 'helpers/presenter_helper'

ActionController::Base.send :helper, PresenterHelper