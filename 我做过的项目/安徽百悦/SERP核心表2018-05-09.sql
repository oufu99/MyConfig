
 SELECT * FROM dbo.tb_setting WHERE setting_catalog_code='rebateType' and manufacturer_id = 10563 --���ñ�


GOTO:
SELECT * FROM  dbo.tb_manufacturer   --���̱�

SELECT * FROM dbo.tb_customer_catalog WHERE manufacturer_id = 10466	--�����̼����
SELECT * FROM dbo.tb_user WHERE manufacturer_id = 10466	--�û���
SELECT * FROM dbo.tb_customer_10466 WHERE is_active = 1	--�����̱�  audit_status(���״̬ 0δ��� 1���ͨ�� 2��˲�ͨ��)

GOTO:

SELECT * FROM dbo.tb_recommend_money_history_10466	--Ӷ���б�(������) *recommend_custId Ϊ����տ���
SELECT * FROM dbo.cust_personal_center_10466	--�������ı�
SELECT * FROM dbo.cust_personal_center_in_10466		--����������ˮ�����
SELECT * FROM dbo.cust_personal_center_out_10466	--����������ˮ�����

GOTO:

SELECT * FROM dbo.tb_order_10466 WHERE is_active = 1	--������( orery_type:0������  1����� 2ֱ���� 3�׵�)
SELECT * FROM dbo.tb_order_detail_10466		--������ϸ��

GOTO:

SELECT * FROM dbo.tb_product WHERE manufacturer_id = 10466	--��Ʒ��
SELECT * FROM dbo.tb_goods WHERE manufacturer_id = 10466	--��Ʒ��(���SKU)

SELECT * FROM dbo.Ordered_Price_10466	--��Ʒ�۸��(ÿ�������̼����Ӧһ���۸�)

GOTO:

SELECT * FROM dbo.tb_Tracking_Company WHERE manuID = 10466	--��ݹ�˾��
SELECT * FROM dbo.tb_FreightSeting WHERE ManuId = 10466 --��ݷ�������(����Ĭ�ϼ�¼ *isDef ΪĬ��ֵ)

SELECT * FROM dbo.tb_rule_mapping_class WHERE manu_id = 10466	--url���ر�(�ֶ�����)

SELECT * FROM dbo.tb_manu_mapping_procedure WHERE manu_id = 10466	--�洢����ִ�б�

SELECT * FROM dbo.tb_setting WHERE manufacturer_id = 10466 --���ñ�

SELECT * FROM dbo.tb_cust_upgradeorder_10466	--�������뵥

SELECT * FROM dbo.Commission_Withdrawals_10466	--�����б�

EXEC sp_order_Audit_recommended_10466

SELECT * FROM dbo.CashVoucher_10466		--��ֵ

SELECT * FROM dbo.tb_stock_10466	--��Ʒ����

SELECT * FROM dbo.tb_cutomer_address_10466	--�ջ���ַ��


SELECT * FROM dbo.tb_customer_10466 WHERE oldparent_str <> ',0,2,3,4,' and oldparent_str LIKE ',0,2,3,4,%'


-- pro_Insert_tb_recommend_money_history_10487 --�洢���̣��¶ȷֺ� ,10498|10499

