USE [serp3]
GO
/****** Object:  StoredProcedure [dbo].[sp_team_month_Dividend_10563]    Script Date: 2018/8/2 9:14:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[RepairData_10563]
AS
    BEGIN
        BEGIN TRY	
            BEGIN TRAN;
          

	 SELECT  * INTO #temoHistory_10563  FROM tb_recommend_money_history_10563 WHERE type IN (22,37)

	WHILE(SELECT COUNT(*) FROM #temoHistory_10563)>0	
	BEGIN
		DECLARE @ID INT,
		@money DECIMAL(18,2),
		@custId INT,
		@type INT
		SELECT TOP 1 @ID=ID,@money=money,@custId=recommend_custId,@type=type FROM #temoHistory_10563
		IF(@money>0 AND @custId!=0)
		BEGIN
		IF(@type=37)
		BEGIN
		    --���������ĵ�Ǯ
			 insert tb_RepairData_10563 VALUES (@custId,@money,GETDATE(),'��ȥ���õ�Ӷ��',0)
				UPDATE dbo.cust_personal_center_10563 SET commission_account=commission_account-@money WHERE cust_id=@custId
		END
				--�ϼ��۵��ļ���ȥ
				ELSE IF(@type=22)	
				BEGIN
				insert tb_RepairData_10563 VALUES (@custId,@money,GETDATE(),'���Ӵ����ȥӶ��',1)
				    UPDATE dbo.cust_personal_center_10563 SET commission_account=commission_account+@money WHERE cust_id=@custId
				END
		END
			PRINT @ID
		DELETE #temoHistory_10563 WHERE ID=@ID
		DELETE	tb_recommend_money_history_10563 WHERE ID=@ID
	END

            PRINT '�ύ����';
            COMMIT TRAN;
        END TRY
        BEGIN CATCH
            PRINT '�ع�����';
            ROLLBACK TRAN;
        END CATCH;
    END;

/**
��ȡ���ж��� CstmId,����ҵ��,���Էֺ��Ǯ,oldparentStr
*/





