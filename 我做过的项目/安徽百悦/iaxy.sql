--EXEC  sp_team_month_Dividend_10563


SELECT parent_id, * FROM tb_customer_10563 WHERE tb_customerID=149

SELECT * FROM dbo.tb_setting WHERE setting_catalog_code='rebateType' and manufacturer_id = 10563
 
--SELECT * INTO tb_recommend_money_history_10563_temp1 FROM tb_recommend_money_history_10563_temp  
--SELECT * into cust_personal_center_out_10563_temp1 FROM cust_personal_center_out_10563_temp  
--SELECT * into cust_personal_center_in_10563_temp1 FROM cust_personal_center_in_10563_temp  
--SELECT * INTO cust_personal_center_10563_tmep1 FROM cust_personal_center_10563_tmep


--22 扣下级月分红返佣    37团队月分红奖励

--871.30
SELECT  *  FROM tb_recommend_money_history_10563 WHERE type IN (22,37)
SELECT *    FROM cust_personal_center_out_10563_temp1 WHERE source IN (22,37)
SELECT *    FROM cust_personal_center_in_10563_temp1 WHERE source IN (22,37)
--3281.56
SELECT  SUM(commission_account)   FROM cust_personal_center_10563_tmep1 

--算完结果 2410.26

 
EXEC RepairData_10563

SELECT * FROM tb_RepairData_10563

SELECT * FROM dbo.cust_personal_center_in_10563 WHERE cust_id=61