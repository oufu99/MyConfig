USE [serp3]
GO
/****** Object:  StoredProcedure [dbo].[Import_CustomerInfo_10596]    Script Date: 2018/9/20 9:22:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[Import_CustomerInfo_10596]
    @express_info dbo.tb_Customer_info_10596 READONLY ,
    @manu_id INT ,
    @error_msg NVARCHAR(500) OUTPUT
AS
    DECLARE @sql NVARCHAR(3000) ,
        @custID INT;
    DECLARE @errorSun INT= 0; --定义错误计数器
        --临时表
    CREATE TABLE #tb_cust
        (
    [num] [INT] NULL,
	[name] [NVARCHAR](100) NULL,
	[customer_catalog_id] [INT] NULL,
	provice [NVARCHAR](500) NULL,
	city [NVARCHAR](500) NULL,
	district [NVARCHAR](500) NULL,
	[address] [NVARCHAR](500) NULL,
	[contact] [NVARCHAR](100) NULL,
	weixi_no [NVARCHAR](100) NULL,
	[mobile] [NVARCHAR](20) NULL,
	[id_card] [NVARCHAR](100) NULL,
	zhiniaoku [INT] NULL,
	lalaku [INT] NULL,
	[account_money] [DECIMAL](18, 2) NULL
        );
		--验证插入的excel中有没有手机号码重复
    DECLARE @i INT= 1;
    DECLARE @count INT;
    DECLARE @mobile NVARCHAR(20)= '';

    PRINT '开始111';

    SELECT  @count = COUNT(1)
    FROM    @express_info;
    WHILE ( @i <= @count )
        BEGIN
            SELECT  @mobile = mobile
            FROM    @express_info
            WHERE   num = @i;
            IF ( SELECT COUNT(1)
                 FROM   @express_info
                 WHERE  mobile = @mobile
               ) > 1
                BEGIN
                    SET @error_msg = @mobile + ',' + @error_msg;
                END;
            SET @i = @i + 1;
        END;
    PRINT '开始222';
    PRINT @error_msg;
    IF ( @error_msg != '' )
        BEGIN
            SET @error_msg = @error_msg + ',在此Excel中重复出现！';
            RETURN;	
        END;
        --判断数据库中是否重复
    PRINT '开始333';
    SET @sql = ' select * from @express_info where mobile in 
        (select mobile from tb_customer_' + CAST(@manu_id AS NVARCHAR(100))
        + ' where is_active=1)';
     
    INSERT  INTO #tb_cust
            EXEC sp_executesql @sql,
                N'@express_info tb_Customer_info_10596 READONLY',
                @express_info;
        
    PRINT '开始444'; 
    SET @i = 1;
    SELECT  @count = COUNT(1)
    FROM    #tb_cust;
    SET @error_msg = CAST(@count AS NVARCHAR(20)) + '个';
        --判断手机号码是否存在
    IF @count > 0
        BEGIN
            WHILE ( @i <= @count )
                BEGIN
        
                    SELECT  @mobile = mobile
                    FROM    #tb_cust
                    WHERE   num = @i;
                    SET @error_msg = @mobile + ',' + @error_msg;
                    SET @i = @i + 1;
                END;
            SET @error_msg = @error_msg + ',手机号码已经存在！';
            RETURN;
        END;
    ELSE
        BEGIN
		--前面验证重复,这里进行插入
            BEGIN TRANSACTION;   
       --插入代理商表 
            SELECT  @count = COUNT(1)
            FROM    @express_info;	
            SET @i = 1;
            WHILE ( @i <= @count )
                BEGIN
                    SET @sql = 'insert into tb_customer_'
                        + CAST(@manu_id AS NVARCHAR(100))
                        + '(
       name ,code,customer_catalog_id,provice,city,district,address ,weixi_no,contact ,mobile ,
       remark ,audit_status  ,id_card ,is_active ,manufacturer_id ,createtime)
       SELECT name ,'''',customer_catalog_id,provice,city,district ,address ,weixi_no,contact ,mobile ,''导入代理商'' ,1 ,id_card ,1 ,'
                        + CAST(@manu_id AS NVARCHAR(100))
                        + ' ,getdate() FROM @express_info where num=@i;';
			 
                    EXEC sp_executesql @sql,
                        N'@express_info tb_Customer_info_10596 READONLY,@i int',
                        @express_info, @i;
                    SELECT  @custID = @@identity;
                    PRINT @custID;
                    SET @errorSun = @errorSun + @@ERROR;
       
                    SET @sql = 'update tb_customer_'
                        + CAST(@manu_id AS NVARCHAR(100))
                        + ' set parent_id=0,parent_str='',0,''+CAST(tb_customerID AS NVARCHAR(20))+'','',oldparent_id=0,
       oldparent_str='',0,''+CAST(tb_customerID AS NVARCHAR(20))+'','' where tb_customerID='
                        + CAST(@custID AS NVARCHAR(100));
                    SET @error_msg = @sql;
                    EXEC(@sql);
                    SET @errorSun = @errorSun + @@ERROR;
        --插入用户表
                    SET @sql = 'insert into tb_user( system_role_id ,custid ,employee_id ,manufacturer_id ,name ,password ,status ,last_login_time ,create_time)
        SELECT -5,' + CAST(@custID AS NVARCHAR(20)) + ',0,'
                        + CAST(@manu_id AS NVARCHAR(20)) + ',
        b.mobile,right(b.mobile,6),0,GETDATE(),GETDATE() FROM @express_info b where num=@i';
		  
                    EXEC sp_executesql @sql,
                        N'@express_info tb_Customer_info_10596 READONLY,@i int',
                        @express_info,@i;
		--处理其他的业务    插入余额表
                    DECLARE @money DECIMAL(18, 2);
                    SELECT  @money = account_money
                    FROM    @express_info
                    WHERE   num = @i;
                    PRINT '金钱结算';
                    PRINT @money; 
                    EXEC dbo.sp_cust_personalcenter_in_currency @cust_id = @custID, -- int
                        @source = 99, -- int
                        @type = 4, -- int
                        @business_id = 0, -- int
                        @value = @money, -- decimal
                        @manufacturer_id = @manu_id, -- int
                        @withdraw_status = 1, -- int
                        @send_status = 0, -- int
                        @tbfieldname = N'', -- nvarchar(200)
                        @msg = N''; -- nvarchar(1000)

							--添加库存 lalaku
						EXEC dbo.sp_order_stock_in_or_out @manuid = @manu_id, -- int
                                @order_id = 0, -- int
                                @cust_id = @custID, -- int  实际增加库存的人
                                @to_cust_id = 0, -- int 调拨的人
                                @product_id = -199, -- int
                                @quantity = lalaku, -- int
                                @type = 1, -- int
                                @in_or_out = N'in', -- nvarchar(20)
                                @mssage = '';
						--添加库存 zhiniaoku
						EXEC dbo.sp_order_stock_in_or_out @manuid = @manu_id, -- int
                                @order_id = 0, -- int
                                @cust_id = @custID, -- int  实际增加库存的人
                                @to_cust_id = 0, -- int 调拨的人
                                @product_id = -199, -- int
                                @quantity = zhiniaoku, -- int
                                @type = 1, -- int
                                @in_or_out = N'in', -- nvarchar(20)
                                @mssage = '';
--插入循环结束
                    SET @i = @i + 1;
                END;
            SET @errorSun = @errorSun + @@ERROR;
        
            IF @errorSun > 0
                BEGIN

                    ROLLBACK TRANSACTION;
                    SET @error_msg = '导入失败！' + @error_msg;
                    PRINT '事物回滚';

                END;

            ELSE
                BEGIN
                    SET @error_msg = '';
                    COMMIT TRANSACTION;
                    PRINT '事物执行';

                END;

        END;
	   
     

