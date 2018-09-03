USE [serp3];
GO
/****** Object:  StoredProcedure [dbo].[proc_tb_customAfter_pingji_10614]    Script Date: 2018/9/3 15:41:55 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
--exec [proc_tb_customAfter_10614] 86,2014
ALTER PROC [dbo].[proc_tb_customAfter_pingji_10614]
    @orderId INT ,
    @manuId INT
AS
    BEGIN
        BEGIN TRY
            BEGIN TRAN;
	    --�ж��Ƿ��Ѿ���˹�
            IF ( ( SELECT   COUNT(*)
                   FROM     tb_order_10614
                   WHERE    ID = @orderId
                            AND status = 1
                 ) = 1 )
                BEGIN
                    DECLARE @fristzengsong INT = 0 ,
                        @secondzengsong INT ,
                        @custId INT ,
                        @targetcustId INT ,--�û��ϼ�
                        @fristcustId INT ,
                        @secondcustId INT ,
                        @catalogId INT ,
                        @fristcatalogId INT ,
                        @secondcatalogId INT ,
                        @goodsId INT , --ȡ������һ����Ʒ,
                        @quanlity INT ,
                        @fanyongmoney DECIMAL(18, 2) ,
                        @Order_num NVARCHAR(30) ,
                        @msg NVARCHAR(500)= '';  
		--�����Ƽ�����������
                    SELECT  @custId = cust_id ,
                            @quanlity = quantity ,
                            @Order_num = Order_num ,
                            @targetcustId = target_cust_id
                    FROM    tb_order_10614
                    WHERE   ID = @orderId;


                    SELECT  @catalogId = a.customer_catalog_id ,
                            @fristcatalogId = b.customer_catalog_id ,
                            @secondcatalogId = c.customer_catalog_id ,
                            @fristcustId = b.tb_customerID ,
                            @secondcustId = c.tb_customerID
                    FROM    tb_customer_10614 a
                            LEFT JOIN tb_customer_10614 b ON a.oldparent_id = b.tb_customerID
                            LEFT JOIN tb_customer_10614 c ON b.oldparent_id = c.tb_customerID
                    WHERE   a.tb_customerID = @custId;
		   
                    SELECT TOP 1
                            @goodsId = goods_id
                    FROM    dbo.tb_order_detail_10614
                    WHERE   order_id = @orderId;	

                    PRINT @goodsId;
                    PRINT @custId;
                    PRINT @fristcatalogId;
                    PRINT @secondcatalogId;
		  
		   --��һ���������С������� �ڶ�������  
                    IF ( @fristcatalogId <= @catalogId )
                        BEGIN
                            IF ( @fristcatalogId = @catalogId )
                                BEGIN
					--��һ��
                                    SELECT TOP 1
                                            @fristzengsong = ISNULL(value, 0)
                                    FROM    tb_setting
                                    WHERE   manufacturer_id = 10614
                                            AND [key] = 'tjYiDaiYongJiuPurchase'
                                            AND setting_catalog_code = CAST(@fristcatalogId AS NVARCHAR(100));
                                    SET @fanyongmoney = CAST(@fristzengsong AS DECIMAL(18,
                                                              2)) * @quanlity;

                                    PRINT @fristzengsong;
                                    PRINT @fanyongmoney; 
                                    EXEC dbo.sp_cust_personalcenter_in @cust_id = @fristcustId, -- int
                                        @source = 21, -- int --��һ���Ƽ���
                                        @type = 1, -- int
                                        @business_id = @orderId, -- int
                                        @value = @fanyongmoney, -- decimal
                                        @manufacturer_id = 10614, -- int
                                        @withdraw_status = 1, -- int
                                        @send_status = 0, -- int
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
                                    VALUES  ( @custId , -- ordered_custId - int
                                              @fanyongmoney , -- money - decimal
                                              @fristcustId , -- recommend_custId - int
                                              @Order_num , -- orderNum - varchar(20)
                                              GETDATE() , -- createTime - datetime
                                              21 , -- type - smallint --�Ƽ���
                                              0 , -- brandId - int
                                              N''  -- json - nvarchar(2000)
							                );
							--���ϼ���Ǯ
                                    IF ( @targetcustId != 0 )
                                        BEGIN
                                            EXEC dbo.sp_cust_personalcenter_out @cust_id = @targetcustId,
                                                @source = 23, @type = 1,
                                                @business_id = @orderId,
                                                @value = @fanyongmoney,
                                                @manufacturer_id = 10614,
                                                @msg = @msg;	
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
                                            VALUES  ( @fristcustId , -- ordered_custId - int
                                                      @fanyongmoney , -- money - decimal
                                                      @targetcustId , -- recommend_custId - int
                                                      @Order_num , -- orderNum - varchar(20)
                                                      GETDATE() , -- createTime - datetime
                                                      23 , -- type - smallint --�Ƽ���
                                                      0 , -- brandId - int
                                                      N''  -- json - nvarchar(2000)
							                        );

                                        END;

                                END;
                            IF ( @secondcatalogId = @catalogId )
                                BEGIN
					--�ڶ���
                                    SELECT TOP 1
                                            @secondzengsong = ISNULL(value, 0)
                                    FROM    tb_setting
                                    WHERE   manufacturer_id = 10614
                                            AND [key] = 'tjErDaiYongJiuPurchase'
                                            AND setting_catalog_code = CAST(@secondcatalogId AS NVARCHAR(100));
                                    SET @fanyongmoney = CAST(@fristzengsong AS DECIMAL(18,
                                                              2)) * @quanlity;


                                    PRINT @secondzengsong;
                                    PRINT @fanyongmoney; 


                                    EXEC dbo.sp_cust_personalcenter_in @cust_id = @secondcustId, -- int
                                        @source = 22, -- int --�ڶ����Ƽ���
                                        @type = 1, -- int
                                        @business_id = @orderId, -- int
                                        @value = @fanyongmoney, -- decimal
                                        @manufacturer_id = 10614, -- int
                                        @withdraw_status = 1, -- int
                                        @send_status = 0, -- int
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
                                    VALUES  ( @custId , -- ordered_custId - int
                                              @fanyongmoney , -- money - decimal
                                              @secondcustId , -- recommend_custId - int
                                              @Order_num , -- orderNum - varchar(20)
                                              GETDATE() , -- createTime - datetime
                                              22 , -- type - smallint --�ڶ����Ƽ���
                                              0 , -- brandId - int
                                              N''  -- json - nvarchar(2000)
							                );
						
							--���ϼ���Ǯ
                                    IF ( @targetcustId != 0 )
                                        BEGIN
                                            EXEC dbo.sp_cust_personalcenter_out @cust_id = @targetcustId,
                                                @source = 24, @type = 1,
                                                @business_id = @orderId,
                                                @value = @fanyongmoney,
                                                @manufacturer_id = 10614,
                                                @msg = @msg;	
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
                                            VALUES  ( @secondcustId , -- ordered_custId - int
                                                      @fanyongmoney , -- money - decimal
                                                      @targetcustId , -- recommend_custId - int
                                                      @Order_num , -- orderNum - varchar(20)
                                                      GETDATE() , -- createTime - datetime
                                                      24 , -- type - smallint --�Ƽ���
                                                      0 , -- brandId - int
                                                      N''  -- json - nvarchar(2000)
							                        );
                                        END;
                                END;   
                        END;
                END;
            PRINT '�ύ����';
            COMMIT TRAN;
        END TRY
        BEGIN CATCH
            PRINT '�ع�����';
            ROLLBACK TRAN;
        END CATCH; 
    END;


 
