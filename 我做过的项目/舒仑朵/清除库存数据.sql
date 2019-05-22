 

 SELECT *
 FROM   tb_customer_10532
 WHERE  tb_customerID = 209;

--Çå³ý¶©µ¥
 SELECT *
 FROM   tb_order_10532
 WHERE  cust_id = 209
        AND is_active = 1;
--UPDATE  tb_order_10532 SET is_active=0 WHERE  cust_id=209  AND is_active=1


 SELECT * FROM   stock_in_or_out_10532; 
--UPDATE  tb_stock_10532 SET virtual_stock=0
 SELECT * FROM   stock_in_or_out_10532  WHERE  cust_id = 209;
--delete stock_in_or_out_10532 WHERE cust_id=209
--UPDATE  tb_stock_10532 SET virtual_stock=2 WHERE cust_id=209 AND product_id=9444

 
 