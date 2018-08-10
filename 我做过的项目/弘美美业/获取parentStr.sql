--UPDATE tb_customer_10583 SET  parent_id=38,oldparent_id=38 WHERE tb_customerID=41



DECLARE @tb_CustomerID INT=41 , @manuID INT=10583, @parent_str NVARCHAR(50) , @oldparent_str  NVARCHAR(50) ,@p_custId INT 

EXEC sp_customer_GetParentStrAndOldParentStr @tb_CustomerID, @manuID, @parent_str OUTPUT, @oldparent_str OUTPUT,@p_custId OUTPUT
PRINT @p_custId
PRINT @parent_str
PRINT @oldparent_str

--,0,28,31,35,
SELECT oldparent_id,parent_id,  * FROM tb_customer_10583 
 
 SELECT * FROM dbo.tb_customer_catalog where  manufacturer_id=10596