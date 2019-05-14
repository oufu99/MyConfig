--UPDATE   tb_order_10532 SET is_active=0  WHERE cust_id=366 AND create_time>'2019-05-13'   

--UPDATE  tb_stock_10532 SET virtual_stock=6  WHERE cust_id=366 AND product_id=9445 --原来-3
--UPDATE  tb_stock_10532 SET virtual_stock=1  WHERE cust_id=366 AND product_id=9447 --原来-1
--舒仑朵专用 --UPDATE dbo.cust_personal_center_10532  SET integral_account=14 WHERE cust_id=366  --原来36

SELECT * FROM   tb_stock_10532   WHERE cust_id=366  

--9448
 SELECT * FROM dbo.cust_personal_center_in_10532   ORDER BY create_time desc	
 
SELECT * FROM stock_in_or_out_10532 WHERE cust_id=366  AND product_id=9448  ORDER BY create_time desc	
 
-- 总积分14分
