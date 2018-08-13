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
    --��˶����¼
            DECLARE @existence INT;
	--��ѯ��������˼�¼����˼�¼����
            SELECT  @existence = COUNT(1)
            FROM    tb_customer_audit_10596
            WHERE   to_audit_customer_id = @cust_id;
            PRINT '��ѯ��������˼�¼����˼�¼����';
            PRINT @existence;

    --�Ƿ��һ�����
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
 
                    PRINT '��ȡ����';
                    PRINT @Money;

                    DECLARE @oldparent_id INT;							--�Ƽ��ϼ�������ID
                    DECLARE @parent_id INT;								--�û��ϼ�������ID
                    DECLARE @oldcustomer_catalog_id INT;				--�Ƽ��ϼ������̼���

		--��ȡ�ô����̵��Ƽ�������ID
                    SELECT  @oldparent_id = oldparent_id ,
                            @parent_id = parent_id
                    FROM    dbo.tb_customer_10596
                    WHERE   tb_customerID = @cust_id;

		--�����Ƽ�������ID����ȡ�Ƽ��ϼ������̼���
                    SELECT  @oldcustomer_catalog_id = customer_catalog_id
                    FROM    dbo.tb_customer_10596
                    WHERE   tb_customerID = @oldparent_id;

                    PRINT '��ȡ�Ƽ��ϼ������̼���ID';
                    PRINT @oldparent_id;
                    PRINT @parent_id;
                    PRINT @oldcustomer_catalog_id;

		--����ļ����
                    EXEC dbo.sp_cust_personalcenter_in @cust_id = @oldparent_id, -- int
                        @source = 14, -- ��Դ ,�Զ���
                        @type = 1, -- int  -- 1-Ӷ��,2-����,3-���,4-�˻���5����֤��
                        @business_id = 0, -- int
                        @value = @Money, -- decimal
                        @manufacturer_id = 10596, -- int
                        @withdraw_status = 1, -- int -- 0-�������� 1-������
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
                              '��ļ��' ,
                              GETDATE() ,
                              14 ,
                              0 ,
                              ''
                            );

                    PRINT '��ļ�����';
                    PRINT @Msg;  


		--��ȡ�缶�Ƽ���������Ƽ��ϼ������̼�������Ƽ������̼�����ƽ��/���Ƹ�
                    IF @oldcustomer_catalog_id > @catalog_id
                        BEGIN	
                            DECLARE @RecommendMoney DECIMAL(18, 2);					--ƽ���Ƽ���/�缶�Ƽ��� ���
                            SELECT  @RecommendMoney = CAST(value AS DECIMAL(18,
                                                              2))
                            FROM    dbo.tb_setting
                            WHERE   manufacturer_id = 10596
                                    AND [key] = 'kuajijiang'
                                    AND setting_catalog_code = CAST(@catalog_id AS NVARCHAR(50));
		
		 
                            PRINT '�缶�Ƽ������';
                            PRINT @RecommendMoney;   

		
				---�Ƽ��ϼ������̻��Ӷ��(ƽ���Ƽ���/�缶�Ƽ���)
                            EXEC dbo.sp_cust_personalcenter_in @cust_id = @oldparent_id, -- int
                                @source = 15, -- int  
                                @type = 1, -- int  -- 1-Ӷ��,2-����,3-���,4-�˻���5����֤��
                                @business_id = 0, -- int
                                @value = @RecommendMoney, -- decimal
                                @manufacturer_id = 10596, -- int
                                @withdraw_status = 1, -- int -- 0-�������� 1-������
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
                                      '�缶�Ƽ���'
                                    );
                            IF @parent_id != 0
                                BEGIN
                                    EXEC dbo.sp_cust_personalcenter_out @cust_id = @parent_id, -- int
                                        @source = 16, -- int  
                                        @type = 1, -- int  -- 1-Ӷ��,2-����,3-���,4-�˻���5����֤��
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
                                              '֧���¼�����Ŀ缶�Ƽ���'
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
            IF @@TRANCOUNT > 0---------------�ж���û������
                BEGIN
                    ROLLBACK TRAN;----------�ع�����
                    RETURN;
                END; 
        END CATCH;
    END; 
