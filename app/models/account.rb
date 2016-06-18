class Account < ActiveRecord::Base
  validates_presence_of :insales_id
  validates_presence_of :insales_subdomain
  validates_presence_of :password
  has_one :account_info

  def allow_work?
  	if self.account_info
  		return self.account_info.allow_work
  	end
  	return false
  end

  def auto_update?
  	if self.account_info
  		return self.account_info.auto_update
  	end
  	return false
  end

  def not_updated_today?
    if self.account_info
      return true if self.account_info.last_seo_update.nil?
      return true if ( Time.now > self.account_info.last_seo_update  + 1.day )
    end
    return false
  end

  def last_seo_update
  	d = nil
  	if self.account_info
  		d = self.account_info.last_seo_update
  	end
  	return "" if d.nil?
  	return d.strftime('%d.%m.%Y')
  end

  def max_page_num
    num = 1
    if self.account_info
      num = self.account_info.max_products_count / 250 + 1
    end
    return num
  end

end
