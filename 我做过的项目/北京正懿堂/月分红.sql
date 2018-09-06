USE [serp3]
GO
/****** Object:  StoredProcedure [dbo].[sp_team_month_Dividend_10614]    Script Date: 2018/9/6 13:40:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_team_month_Dividend_10614]
AS
    BEGIN
        BEGIN TRY	
            BEGIN TRAN;
            PRINT '开始你的表演';
		--团队分红临时表
              CREATE TABLE #resultT--结果集
                (
                  Id INT IDENTITY(1, 1) ,
                  cstmId INT ,
                  yeji INT ,
                  fenhon DECIMAL(18, 2) ,--分红
             
		        );
            DECLARE @i INT = 1;
            DECLARE @tempCstmId INT ,
                @tempcatalog INT ,
                @tempYeJi DECIMAL(18, 2) ,
                @tempSetting DECIMAL(18, 2) ,
                @tempFenhon DECIMAL(18, 2) ,
                @max_catalog INT,
				@second_catalog INT,
				@manufacturer_id INT=10614,
				@nahuo_custId int; --最高级别的代理
	 
		--只有最高级别才会返佣
            
                SELECT  @max_catalog = tb_customer_catalogID
                FROM    dbo.tb_customer_catalog
                WHERE   manufacturer_id = 10614
                        AND parent_id = 0;
 
			--把所有的代理都查出来然后按照推荐链倒序 最末端的就在第一条了
                INSERT  #resultT
                        ( cstmId ,
                          yeji ,
                          fenhon  
			            )
                        SELECT  tb_customerID ,
                                0.00 ,
                                0.00   
                        FROM    dbo.tb_customer_10614
						WHERE  --1=1 
						(customer_catalog_id=@max_catalog)
						--and tb_customerID IN(5)  --调试的语句 发布时注释
                      
				PRINT '开始调试'
				    --遍历临时表中所有数据
                WHILE @i <= ( SELECT    COUNT(1)
                              FROM      #resultT
                            )
                    BEGIN
                        SELECT  @tempCstmId = cstmId
							FROM    #resultT
                        WHERE   Id = @i;
						--只算自己的业绩
						SELECT @nahuo_custId=parent_id FROM tb_customer_10614 WHERE tb_customerID=@tempCstmId
						PRINT '拿货上级'+CAST(@nahuo_custId AS NVARCHAR(50))

                        SELECT  @tempYeJi = ISNULL(SUM(amount),0)
                        FROM    tb_order_10614
                        WHERE   status = 1   
                                AND order_type!=3 AND    order_type!=1  --3是升级单,1是提货单
                               --AND create_time BETWEEN DATEADD(mm,
                               --                             DATEDIFF(mm, 0,
                               --                               DATEADD(MONTH,
                               --                               -1, GETDATE())),
                               --                             0)
                               --             AND     DATEADD(mm,
                               --                             DATEDIFF(mm, 0,
                               --                               DATEADD(MONTH, 0,
                               --                               GETDATE())), 0)
                                AND cust_id=@tempCstmId;
                        PRINT '此次循环代理商' + CAST(@tempCstmId AS NVARCHAR(30));
                        PRINT '此次循环业绩'+ CAST(@tempYeJi AS NVARCHAR(30));
			 
				--计算团队分红

                        SELECT TOP 1
                                @tempSetting = ISNULL(CAST(value AS DECIMAL),
                                                      0) / 100
                        FROM    dbo.tb_setting
                        WHERE   manufacturer_id = 10614
                                AND setting_catalog_code = 'fandian'
                                AND is_active = 1
                                AND CAST([key] AS DECIMAL(18,2)) <= @tempYeJi
                        ORDER BY CAST([key] as DECIMAL(18,2)) DESC;
                        PRINT '比例';
                        PRINT @tempSetting;
						  PRINT @tempYeJi;
                        SET @tempFenhon = @tempYeJi
                            * ISNULL(@tempSetting, 0);
                         set @tempSetting=0;
				PRINT '分红的钱'+CAST(@tempFenhon AS NVARCHAR(30))
                                IF @tempFenhon > 0
                                    BEGIN
				--执行分红
								    	 PRINT '开始分红'
                                        EXEC dbo.sp_cust_personalcenter_in_currency @cust_id = @tempCstmId, -- int
                                            @source = 30, -- int
                                            @type = 1, -- int
                                            @business_id = 0, -- int
                                            @value = @tempFenhon, -- decimal
                                            @manufacturer_id = 10614, -- int
                                            @withdraw_status = 1, -- int
                                            @send_status = 0, -- int
                                            @tbfieldname = N'', -- nvarchar(200)
                                            @msg = N''; -- nvarchar(1000)
                                        INSERT  INTO dbo.tb_recommend_money_history_10614
                                                ( ordered_custId ,
                                                  money ,
                                                  recommend_custId ,
                                                  orderNum ,
                                                  createTime ,
                                                  type ,
                                                  brandId ,
                                                  json
                                                )
                                        VALUES  ( 0 ,
                                                  @tempFenhon ,
                                                  @tempCstmId ,
                                                  '' ,
                                                  GETDATE() ,
                                                  30 ,
                                                  0 ,
                                                  N''
                                                );

									 
								
									   
                                    
									 END;  
                               SET @i = @i + 1;  
                            END
                  
            SELECT  *
            FROM    #resultT;
            PRINT '提交事务';
            COMMIT TRAN;
        END TRY
        BEGIN CATCH
            PRINT '回滚事务';
            ROLLBACK TRAN;
        END CATCH;
    END;

/**
获取所有董事 CstmId,个人业绩,可以分红的钱,oldparentStr
*/





