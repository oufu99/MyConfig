--jialin_ou  13222221111 221111  custId 18
--shulunduotest1    123456 custId 45


SELECT * FROM tb_integral_history_10532 ORDER BY createtime desc	

SELECT * FROM tb_customer_10532 WHERE name='shulunduotest1'

SELECT * FROM tb_user WHERE manufacturer_id=10532   AND name='shulunduotest1'

--µØÖ· ¸ù¾Ýsign desc
--http://shulunduo.mobile.cn/m/custom/pinkmifei/AddressList.aspx
SELECT  * FROM tb_cutomer_address_10532 WHERE cust_id= 18  AND ID=6 and is_active=1

SELECT * FROM dbo.ExpressKuaiDi100Setting