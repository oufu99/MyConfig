EXEC dbo.sp_cust_personalcenter_in_currency 
		      @cust_id = @custId, -- int
		      @source = 5, -- int 
		      @type = 5, -- int  -- 1-Ӷ��,2-����,3-���,4-�˻���5����֤��
		      @business_id = 0, -- int
		      @value = @bujiao, -- decimal
		      @manufacturer_id = 10646, -- int
		      @withdraw_status = 1, -- int -- 0-�������� 1-������
		      @send_status = 0, -- int
		      @tbfieldname='bond_account'--�Զ������ֶΣ���֤��