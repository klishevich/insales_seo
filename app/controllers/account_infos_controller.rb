class AccountInfosController < ApplicationController
	# before_filter :authenticate

	def index
		@accounts = Account.all.order(:id)
	end

	def new
		@account = Account.find(params[:account_id])
		@account_info = AccountInfo.new
		@account_info.max_products_count = 5000
		@account_info.day_to_update = 90
		@account_info.allow_work = true 
	end

	def create
		@account = Account.find(params[:account_id])
		@account_info = @account.build_account_info(account_info_params)
		if @account_info.save
			flash[:success] = t(:saved_successfuly)
			redirect_to edit_account_account_info_path(@account)
		else
			render 'new'
		end  
	end

	def edit
		@account = Account.find(params[:account_id])
		@account_info=@account.account_info
	end

	def update
		@account = Account.find(params[:account_id])
		@account_info = @account.account_info
		if @account_info.update_attributes(account_info_params)
			flash[:success] = t(:saved_successfuly)
			redirect_to edit_account_account_info_path(@account)
		else
			render 'edit'
		end
	end

	private

	def account_info_params
		params.require(:account_info).permit( :max_products_count, :auto_update, :seo_field_identifier, :day_to_update, 
			:allow_work, :admin, :last_seo_update)
	end 
end
