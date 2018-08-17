

DECLARE @manuID  INT=-

DELETE FROM dbo.tb_user WHERE manufacturer_id=@manuID AND system_role_id!='-10'
EXEC('DELETE FROM dbo.tb_customer_'+@manuID)
DELETE FROM dbo.tb_product WHERE manufacturer_id=@manuID
DELETE FROM dbo.tb_goods WHERE manufacturer_id=@manuID
DELETE FROM dbo.tb_month_bonus WHERE manuID=@manuID
EXEC('DELETE FROM dbo.Ordered_Price_'+@manuID)
DELETE FROM dbo.tb_brand WHERE manufacturer_id=@manuID
DELETE FROM dbo.tb_product_catalog WHERE manufacturer_id=@manuID
DELETE FROM dbo.tb_product_unit WHERE manufacturer_id=@manuID
DELETE FROM dbo.tb_goods_property WHERE manufacturer_id=@manuID
EXEC('DELETE FROM dbo.tb_recommend_money_history_'+@manuID)
EXEC('DELETE FROM dbo.tb_order_'+@manuID)
EXEC('DELETE FROM dbo.tb_order_detail_'+@manuID)
DELETE FROM dbo.BankInformation WHERE manufacturer_id=@manuID
DELETE FROM dbo.tb_notice WHERE send_manufacturer_id=@manuID
EXEC('DELETE FROM dbo.cust_personal_center_'+@manuID)
EXEC('DELETE FROM dbo.cust_personal_center_in_'+@manuID)
EXEC('DELETE FROM dbo.cust_personal_center_out_'+@manuID)
EXEC('DELETE FROM dbo.tb_order_copy_'+@manuID)
EXEC('DELETE FROM dbo.tb_cutomer_address_'+@manuID)
EXEC('DELETE FROM dbo.tb_mifei_sucai_'+@manuID)
EXEC('DELETE FROM dbo.tb_cust_upgradeorder_'+@manuID)
EXEC('DELETE FROM dbo.stock_in_or_out_'+@manuID)
EXEC('DELETE FROM dbo.tb_stock_'+@manuID)
EXEC('DELETE FROM dbo.tb_noticeNew_'+@manuID)
EXEC('DELETE FROM dbo.Commission_Withdrawals_'+@manuID)
EXEC('DELETE FROM dbo.CashVoucher_'+@manuID)
DELETE FROM dbo.tb_mf_mysaleprofit WHERE manufacturer_id=@manuID
EXEC('DELETE FROM dbo.tb_CapitalPool_'+@manuID)
EXEC('DELETE FROM dbo.tb_CapitalPool_detail_'+@manuID)
EXEC('DELETE FROM dbo.tb_withdrawals_order_'+@manuID)
EXEC('DELETE FROM dbo.tb_customer_Assessment_'+@manuID)
EXEC('DELETE FROM dbo.tb_send_'+@manuID)
EXEC('DELETE FROM dbo.tb_send_details_'+@manuID)
EXEC('DELETE FROM dbo.tb_order_send_'+@manuID)
EXEC('DELETE FROM dbo.tb_receive_'+@manuID)
EXEC('DELETE FROM dbo.tb_receive_details_'+@manuID)

--导购
EXEC('DELETE FROM dbo.tb_activity where manufacturer_id='+@manuID)
EXEC('DELETE FROM dbo.tb_sales where manufacturer_id='+@manuID)
EXEC('DELETE FROM dbo.tb_sales_redPackage_history_'+@manuID)
EXEC('DELETE FROM dbo.tb_sales_scan_history_'+@manuID)
--个人中心
EXEC('DELETE FROM dbo.tb_personal_center_'+@manuID)
EXEC('DELETE FROM dbo.tb_personal_center_in_'+@manuID)
EXEC('DELETE FROM dbo.tb_personal_center_out_'+@manuID)
EXEC('DELETE FROM dbo.tb_personal_center_withdrawals_'+@manuID)
EXEC('DELETE FROM dbo.tb_public_product where manufacturer_id='+@manuID)
