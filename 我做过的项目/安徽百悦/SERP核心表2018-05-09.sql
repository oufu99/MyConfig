
 SELECT * FROM dbo.tb_setting WHERE setting_catalog_code='rebateType' and manufacturer_id = 10563 --配置表


GOTO:
SELECT * FROM  dbo.tb_manufacturer   --厂商表

SELECT * FROM dbo.tb_customer_catalog WHERE manufacturer_id = 10466	--代理商级别表
SELECT * FROM dbo.tb_user WHERE manufacturer_id = 10466	--用户表
SELECT * FROM dbo.tb_customer_10466 WHERE is_active = 1	--代理商表  audit_status(审核状态 0未审核 1审核通过 2审核不通过)

GOTO:

SELECT * FROM dbo.tb_recommend_money_history_10466	--佣金列表(可提现) *recommend_custId 为金额收款人
SELECT * FROM dbo.cust_personal_center_10466	--个人中心表
SELECT * FROM dbo.cust_personal_center_in_10466		--个人中心流水进入表
SELECT * FROM dbo.cust_personal_center_out_10466	--个人中心流水外出表

GOTO:

SELECT * FROM dbo.tb_order_10466 WHERE is_active = 1	--订单表( orery_type:0补货单  1提货单 2直购单 3首单)
SELECT * FROM dbo.tb_order_detail_10466		--订单明细表

GOTO:

SELECT * FROM dbo.tb_product WHERE manufacturer_id = 10466	--产品表
SELECT * FROM dbo.tb_goods WHERE manufacturer_id = 10466	--商品表(规格SKU)

SELECT * FROM dbo.Ordered_Price_10466	--商品价格表(每个代理商级别对应一个价格)

GOTO:

SELECT * FROM dbo.tb_Tracking_Company WHERE manuID = 10466	--快递公司表
SELECT * FROM dbo.tb_FreightSeting WHERE ManuId = 10466 --快递费用设置(包含默认记录 *isDef 为默认值)

SELECT * FROM dbo.tb_rule_mapping_class WHERE manu_id = 10466	--url拦截表(手动插入)

SELECT * FROM dbo.tb_manu_mapping_procedure WHERE manu_id = 10466	--存储过程执行表

SELECT * FROM dbo.tb_setting WHERE manufacturer_id = 10466 --配置表

SELECT * FROM dbo.tb_cust_upgradeorder_10466	--升级申请单

SELECT * FROM dbo.Commission_Withdrawals_10466	--提现列表

EXEC sp_order_Audit_recommended_10466

SELECT * FROM dbo.CashVoucher_10466		--充值

SELECT * FROM dbo.tb_stock_10466	--商品库存表

SELECT * FROM dbo.tb_cutomer_address_10466	--收货地址表


SELECT * FROM dbo.tb_customer_10466 WHERE oldparent_str <> ',0,2,3,4,' and oldparent_str LIKE ',0,2,3,4,%'


-- pro_Insert_tb_recommend_money_history_10487 --存储过程，月度分红 ,10498|10499

