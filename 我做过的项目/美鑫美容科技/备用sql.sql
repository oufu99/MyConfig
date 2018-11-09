EXEC dbo.sp_cust_personalcenter_in_currency 
		      @cust_id = @custId, -- int
		      @source = 5, -- int 
		      @type = 5, -- int  -- 1-佣金,2-积分,3-红包,4-账户余额，5、保证金
		      @business_id = 0, -- int
		      @value = @bujiao, -- decimal
		      @manufacturer_id = 10646, -- int
		      @withdraw_status = 1, -- int -- 0-不可提现 1-可提现
		      @send_status = 0, -- int
		      @tbfieldname='bond_account'--自定义金额字段：保证金