
--SELECT * FROM dbo.tb_user

SELECT  ROW_NUMBER() OVER ( ORDER BY id ) AS num ,
        name
INTO    #tempDt
FROM    sysobjects
WHERE   xtype = 'u'
        AND ( name LIKE 'Ordered_Price%'
              OR name LIKE 'tb_customer_%'
              OR name LIKE 'tb_personal_center_withdrawals%'
              OR name LIKE 'tb_order%'
              OR name LIKE 'tb_stock%'
              OR name LIKE 'tb_fw_scan_history%'
              OR name LIKE 'tb_agent_authorize%'
              OR name LIKE 'tb_personal_center_pay_setting%'
              OR name LIKE 'tb_personal_center_out%'
              OR name LIKE 'tb_commission%'
              OR name LIKE 'tb_send%'
              OR name LIKE 'tb_receive%'
              OR name LIKE 'tb_order_detail%'
              OR name LIKE 'tb_customer_brand%'
              OR name LIKE 'tb_sales_promotion%'
              OR name LIKE 'tb_customer_audit%'
              OR name LIKE 'tb_cust_catalog_chage_history%'
              OR name LIKE 'tb_goods_relation_code%'
              OR name LIKE 'tb_invite_code%'
              OR name LIKE 'tb_personal_center%'
              OR name LIKE 'tb_product_redPackage_history%'
              OR name LIKE 'tb_public_product_integral_history%'
              OR name LIKE 'tb_public_product_quality%'
              OR name LIKE 'tb_rebate_log%'
              OR name LIKE 'tb_recommend_money_history%'
              OR name LIKE 'tb_sales_redPackage_history_%'
              OR name LIKE 'tb_sales_scan_history%'
              OR name LIKE 'tb_withdraw_diposit%'
              OR name LIKE 'tb_withdrawals_order%'
              OR name LIKE 'tb_wx_userinfo%'
              OR name LIKE '%attendance%'
             
              OR name LIKE 'beautician%'
              OR name LIKE 'bindingPayingPlatform%'
              OR name LIKE 'buyer_order%'
              OR name LIKE 'cust_payment_order%'
              OR name LIKE 'cust_personal_center%'
              OR name LIKE 'tb_activity_comment_%'
              OR name LIKE 'tb_activity_history%'
              OR name LIKE 'tb_activity_point%'
              OR name LIKE 'tb_activity_prize_code%'
              OR name LIKE 'tb_activity_prize_history%'
              OR name LIKE 'tb_activity_public_product%'
              OR name LIKE 'tb_activity_redPacket_send_result%'
              OR name LIKE 'tb_activity_subject%'
              OR name LIKE 'tb_activity_jifen%'
              OR name LIKE 'tb_fucode%'
              OR name LIKE 'tb_redPacket%'
              OR name LIKE 'tb_return%'
              OR name LIKE 'tb_redPacket_relation_code%'
              OR name LIKE 'tb_sales%'
              OR name LIKE 'tb_send%'
              OR name LIKE 'tb_train_video%'
              OR name LIKE 'tb_rebate_point%'
              OR name LIKE 'tb_choujiang%'
              OR name LIKE 'tb_fanli%'
              OR name LIKE 'subject%'
              OR name LIKE 'tb_wx_subscribe%'
              OR name LIKE 'yz_%'----养殖看情况删除
              OR name LIKE 'zz_%'----种殖看情况删除
			  OR name LIKE 'GXL_%'----共享链看情况删除
			  OR name LIKE 'tem_%'
			  OR name LIKE 'temp_%'
			  OR name LIKE 'tb_cutomer_address_%'
			  OR name LIKE 'CashVoucher_%'
			  OR name LIKE 'BankInformation_%'
		      OR name LIKE 'Commission_Withdrawals_%'
			  OR name LIKE 'stock_in_or_out_%'
			  OR name LIKE 'tb_cust_upgradeorder_%'
		      OR name LIKE 'tb_cutomer_address_%'
		      OR name LIKE 'tb_noticeNew_%'
            )
		AND name != 'tb_agent_authorize_level'
        AND name != 'tb_customer_catalog'
		 AND name != 'tb_SendTemplateMassage'
		  AND name != 'tb_sendMsg_interface'
		;
		
			
			
DECLARE @row INT= 1;
DECLARE @count INT= 0;
SELECT  @count = COUNT(1)
FROM    #tempDt;

DECLARE @tb VARCHAR(200);
DECLARE @sql NVARCHAR(2000);
DECLARE @manuId VARCHAR(10)= -11 '10316';
 --厂商


------------删除不需要的表
WHILE ( @row <= @count )
    BEGIN
        SELECT  @tb = name
        FROM    #tempDt
        WHERE   num = @row;
        SET @row += 1;
        IF ( CHARINDEX(@manuId, @tb) = 0 )
            BEGIN
                PRINT 'delete ' + @tb;
                SET @sql = 'delete ' + @tb;

                EXEC(@sql);
	
            END;
        ELSE
            BEGIN
	    
                CONTINUE;
            END;


    END;

--------删除厂商表
DELETE  dbo.tb_user
WHERE   manufacturer_id  NOT IN ( @manuId ,10034);

---------删除用户表
DELETE  FROM dbo.tb_manufacturer
WHERE   tb_manufacturerID  NOT IN ( @manuId ,10034);
--DROP TABLE #tempDt

--删除公众号配置表
delete tb_weixin_public where manufacturer_id!=@manuId

---删除产品，商品表
DELETE  FROM dbo.tb_goods
WHERE   manufacturer_id  NOT IN ( @manuId ,10034);
DELETE  FROM dbo.tb_product
WHERE   manufacturer_id  NOT IN ( @manuId ,10034);
----删除权限
DELETE  FROM dbo.tb_role
WHERE   manufacturer_id  NOT IN ( @manuId ,10034,0);
DELETE  FROM dbo.tb_manu_module
WHERE   manufacturer_id  NOT IN ( @manuId ,10034);
---返佣设置
DELETE  FROM dbo.tb_manu_mapping_procedure
WHERE   manu_id  NOT IN ( @manuId ,10034);


DROP TABLE #tempDt;

----更新厂商的名字
--UPDATE  tb_user
--SET     name = 'rcsy'
--WHERE   manufacturer_id = 10209
--        AND system_role_id = -10; 


------------权限最后删除---------------

--DELETE  FROM dbo.tb_role_permission
--WHERE   manufacturer_id  NOT IN ( @manuId ,10034);
--------删除菜单
--DELETE  FROM dbo.tb_sys_menu
--WHERE   tb_sys_menuID NOT IN ( SELECT   sys_menu_id
--                               FROM     tb_role_permission
--                               WHERE    manufacturer_id  NOT IN ( @manuId ,10034) );
--------删除模块
--DELETE  FROM dbo.tb_sys_module
--WHERE   tb_sys_moduleID NOT IN ( SELECT sys_module_id
--                                 FROM   dbo.tb_manu_module
--                                 WHERE  manufacturer_id  NOT IN ( @manuId ,10034) );





