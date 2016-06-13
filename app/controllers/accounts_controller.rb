class AccountsController < ApplicationController
	# before_filter :authenticate

	def index
		@accounts = Account.all.order(:id)
	end

end
