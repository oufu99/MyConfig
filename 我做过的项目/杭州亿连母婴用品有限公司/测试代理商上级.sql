DECLARE   @parent_str NVARCHAR(500)  ,
    @oldparent_str NVARCHAR(500),
	@parent_id INT 

EXEC sp_customer_GetParentStrAndOldParentStr_10596 50,10596,@parent_str OUTPUT,  @oldparent_str OUTPUT,@parent_id OUTPUT 
SELECT @parent_id,@parent_str,@oldparent_str
 

 SELECT  parent_id FROM tb_customer_10596 WHERE tb_customerID=50
    SELECT customer_catalog_id,parent_str FROM dbo.tb_customer_10596 WHERE tb_customerID=49
  
     SELECT * FROM dbo.tb_customer_10596 WHERE tb_customerID=49
	 
 --这个人是2424级别   要找2423
 

 

SELECT  customer_catalog_id ,
        parent_id ,
        parent_str ,
        oldparent_id ,
        oldparent_str ,
		
        *
FROM    tb_customer_10596
WHERE   tb_customerID IN (26,31 ); --2423钻代    2424总代  2425一级
SELECT * FROM dbo.tb_customer_catalog where  manufacturer_id=10596

  SELECT * FROM tb_user WHERE manufacturer_id=10596 AND custid=47

