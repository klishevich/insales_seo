class AccountsController < ApplicationController
	before_filter :is_admin

	def index
		@accounts = Account.all.order(:id)
	end

end
