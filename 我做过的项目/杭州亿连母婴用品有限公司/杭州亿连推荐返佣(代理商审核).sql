USE [serp3];
GO
/****** Object:  StoredProcedure [dbo].[cust_audit_after_10596]    Script Date: 2018/5/15 17:35:27 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
 
ALTER PROCEDURE [dbo].[cust_audit_after_recommend_10596]
    @cust_id INT ,
    @catalog_id INT
AS
    BEGIN
        BEGIN TRY;
            BEGIN TRAN;	
    --审核冻结记录
            DECLARE @existence INT;
	--查询代理商审核记录表审核记录条数
            SELECT  @existence = COUNT(1)
            FROM    tb_customer_audit_10596
            WHERE   to_audit_customer_id = @cust_id;
            PRINT '查询代理商审核记录表审核记录条数';
            PRINT @existence;

    --是否第一次审核
            IF @existence <= 1
                BEGIN
                    DECLARE @Msg NVARCHAR(1000);
                    SET @Msg = '';

	 
                    DECLARE @Money DECIMAL(18, 2);
                    SELECT  @Money = CAST(value AS DECIMAL(18, 2))
                    FROM    dbo.tb_setting
                    WHERE   manufacturer_id = 10596
                            AND [key] = 'zhaomujiang'
                            AND setting_catalog_code = CAST(@catalog_id AS NVARCHAR(50));
 
                    PRINT '获取奖励';
                    PRINT @Money;

                    DECLARE @oldparent_id INT;							--推荐上级代理商ID
                    DECLARE @parent_id INT;								--拿货上级代理商ID
                    DECLARE @oldcustomer_catalog_id INT;				--推荐上级代理商级别

		--获取该代理商的推荐代理商ID
                    SELECT  @oldparent_id = oldparent_id ,
                            @parent_id = parent_id
                    FROM    dbo.tb_customer_10596
                    WHERE   tb_customerID = @cust_id;

		--根据推荐代理商ID，获取推荐上级代理商级别
                    SELECT  @oldcustomer_catalog_id = customer_catalog_id
                    FROM    dbo.tb_customer_10596
                    WHERE   tb_customerID = @oldparent_id;

                    PRINT '获取推荐上级代理商级别ID';
                    PRINT @oldparent_id;
                    PRINT @parent_id;
                    PRINT @oldcustomer_catalog_id;

		--发招募奖励
                    EXEC dbo.sp_cust_personalcenter_in @cust_id = @oldparent_id, -- int
                        @source = 14, -- 来源 ,自定义
                        @type = 1, -- int  -- 1-佣金,2-积分,3-红包,4-账户余额，5、保证金
                        @business_id = 0, -- int
                        @value = @Money, -- decimal
                        @manufacturer_id = 10596, -- int
                        @withdraw_status = 1, -- int -- 0-不可提现 1-可提现
                        @send_status = 0, -- int
                        @msg = @msg OUTPUT; -- nvarchar(1000)
                    IF ( @Msg != '10' )
                        BEGIN
				 
                            ROLLBACK TRAN;
                            RETURN;
                        END;

                    INSERT  INTO [dbo].[tb_recommend_money_history_10596]
                            ( [ordered_custId] ,
                              [money] ,
                              [recommend_custId] ,
                              [orderNum] ,
                              [createTime] ,
                              [type] ,
                              [brandId] ,
                              [json]
                            )
                    VALUES  ( @cust_id ,
                              @Money ,
                              @oldparent_id ,
                              '招募奖' ,
                              GETDATE() ,
                              14 ,
                              0 ,
                              ''
                            );

                    PRINT '招募奖完毕';
                    PRINT @Msg;  


		--获取跨级推荐奖，如果推荐上级代理商级别跟被推荐代理商级别是平级/低推高
                    IF @oldcustomer_catalog_id > @catalog_id
                        BEGIN	
                            DECLARE @RecommendMoney DECIMAL(18, 2);					--平级推荐奖/跨级推荐奖 金额
                            SELECT  @RecommendMoney = CAST(value AS DECIMAL(18,
                                                              2))
                            FROM    dbo.tb_setting
                            WHERE   manufacturer_id = 10596
                                    AND [key] = 'kuajijiang'
                                    AND setting_catalog_code = CAST(@catalog_id AS NVARCHAR(50));
		
		 
                            PRINT '跨级推荐奖金额';
                            PRINT @RecommendMoney;   

		
				---推荐上级代理商获得佣金(平级推荐奖/跨级推荐奖)
                            EXEC dbo.sp_cust_personalcenter_in @cust_id = @oldparent_id, -- int
                                @source = 15, -- int  
                                @type = 1, -- int  -- 1-佣金,2-积分,3-红包,4-账户余额，5、保证金
                                @business_id = 0, -- int
                                @value = @RecommendMoney, -- decimal
                                @manufacturer_id = 10596, -- int
                                @withdraw_status = 1, -- int -- 0-不可提现 1-可提现
                                @send_status = 0, -- int
                                @msg = @msg OUTPUT; -- nvarchar(1000)
                            INSERT  INTO [dbo].[tb_recommend_money_history_10596]
                                    ( [ordered_custId] ,
                                      [money] ,
                                      [recommend_custId] ,
                                      [orderNum] ,
                                      [createTime] ,
                                      [type] ,
                                      [brandId] ,
                                      [json]
                                    )
                            VALUES  ( @parent_id ,
                                      @RecommendMoney ,
                                      @oldparent_id ,
                                      @RecommendMoney ,
                                      GETDATE() ,
                                      '' ,
                                      0 ,
                                      '跨级推荐奖'
                                    );
                            IF @parent_id != 0
                                BEGIN
                                    EXEC dbo.sp_cust_personalcenter_out @cust_id = @parent_id, -- int
                                        @source = 16, -- int  
                                        @type = 1, -- int  -- 1-佣金,2-积分,3-红包,4-账户余额，5、保证金
                                        @business_id = 0, -- int
                                        @value = @RecommendMoney, -- decimal
                                        @manufacturer_id = 10596, -- int
                                        @msg = @msg OUTPUT; -- nvarchar(1000)
                                    INSERT  INTO [dbo].[tb_recommend_money_history_10596]
                                            ( [ordered_custId] ,
                                              [money] ,
                                              [recommend_custId] ,
                                              [orderNum] ,
                                              [createTime] ,
                                              [type] ,
                                              [brandId] ,
                                              [json]
                                            )
                                    VALUES  ( @oldparent_id ,
                                              @RecommendMoney ,
                                              @parent_id ,
                                              0 ,
                                              GETDATE() ,
                                              16 ,
                                              0 ,
                                              '支付下级代理的跨级推荐奖'
                                            );
                                    IF ( @Msg != '10' )
                                        BEGIN 
                                            ROLLBACK TRAN;
                                            RETURN;
                                        END;
                                    PRINT @Msg;  
                                END;     
                        END;	
		
                END;
            COMMIT TRAN;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0---------------判断有没有事务
                BEGIN
                    ROLLBACK TRAN;----------回滚事务
                    RETURN;
                END; 
        END CATCH;
    END; 
