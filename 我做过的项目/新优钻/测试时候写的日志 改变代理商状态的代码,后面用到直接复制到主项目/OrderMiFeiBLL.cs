using MiFei.DAL;
using MiFei.Model;
using MiFei.Model.Order;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using Ws.Common;
using WsBg.Common;
using WsBg.Web.BLL;
using WsBg.Web.DAL;
using WsBg.Web.Models;
using WsBg.Web.Models.Order;

namespace MiFei.BLL
{
    public class OrderMiFeiBLL
    {
        private static readonly object auditlock = new object();
        private OrderMiFeiDAL orderMiFeiDAL = new OrderMiFeiDAL();
        private OrderDetailMiFeiDAL orderDetailMiFeiDAL = new OrderDetailMiFeiDAL();
        private WxTemplateMsgBLL wxTemplateMsgBLL = new WxTemplateMsgBLL();

        /// <summary>
        /// 代理商政策
        /// </summary>
        private ManuMethodSettingBLL manuMethodSettingBLL = new ManuMethodSettingBLL();

        /// <summary>
        /// 订单审核 列表
        /// </summary>
        public List<OrderMiFeiInfoResult> GetOrderPurchaseGoods(OrderSearchMiFeiModel search)
        {
            return orderMiFeiDAL.GetOrderPurchaseGoods(search);
        }

        /// <summary>
        /// 读取读单详情
        /// </summary>
        public OrderJoinDetailMiFeiInfoResult GetOrderDetail(OrderEditSearchModel search)
        {
            var orderDetailMiFeiBLL = new OrderDetailMiFeiBLL();
            var addressBLL = new AddressBLL();
            var orderPresentBLL = new OrderPresentBLL();

            // 订单
            var result = orderMiFeiDAL.GetOrderDetail(search);

            // 订单详情
            result.OrderDetail = orderDetailMiFeiBLL.GetOrderDetail(new OrderDetailMiFeiSearchModel()
            {
                ManuId = search.ManuId,
                OrderId = search.OrderId,
            });

            // 订单关联
            var orderPresentList = orderPresentBLL.GetList(search.ManuId, search.OrderId);

            // 赠送装详情
            result.OrderDetail.AddRange(orderDetailMiFeiBLL.GetPresentDetail(new OrderDetailMiFeiSearchModel()
            {
                ManuId = search.ManuId,
                OrderIds = orderPresentList.Select(c => c.PresentOrderId).ToArray(),
            }));
            // 发货地址
            result.AddressInfo = addressBLL.GetDefaultAddress(search.ManuId);

            return result;
        }

        /// <summary>
        /// 订单信息
        /// </summary>
        public OrderMiFeiInfoResult GetOrderByOrderNum(int manuId, string orderNum)
        {
            return orderMiFeiDAL.GetOrderByOrderNum(manuId, orderNum) ?? new OrderMiFeiInfoResult();
        }

        /// <summary>
        /// 订单审核 判断
        /// </summary>
        public StringReturn PostOrderAuditJudge(OrderMiFeiInfoResult orderInfo)
        {
            var sReturn = new StringReturn();
            if (orderInfo == null || orderInfo.OrderId <= 0)
            {
                sReturn.Msg = "审核失败，找不到订单信息";
                return sReturn;
            }

            if (orderInfo.Status != (int)OrderStatusEnum.PendingAudit)
            {
                sReturn.Msg = "审核失败，订单非待审核";
                return sReturn;
            }

            if (orderInfo.IsCancel == 1)
            {
                sReturn.Msg = "审核失败，订单已取消";
                return sReturn;
            }
            return sReturn;
        }
        
        /// <summary>
        /// 填写物流信息发货
        /// </summary>
        public bool OrderSend(OrderSendModel info)
        {
            var orderDAL = new OrderDAL();

            // 订单查找
            var orderInfo = orderDAL.GetOrderById(info.ManuId, info.OrderId);

            // 订单发货
            var result = orderDAL.OrderSend(info.ManuId, info.OrderId, info.ExpressCompany, info.CourierNumber);
            if (result)
            {
                // 发货成功，发送模板消息
                wxTemplateMsgBLL.SendWxMsgPickUpOrderSendApi(new OrderSendWxMsg(info.ManuId, info.OrderId));

                // 订单为刚发货时才触发代理商政策
                if ((orderInfo.Status == (int)OrderStatusEnum.PendingSend || orderInfo.Status == (int)OrderStatusEnum.AuditPassed))
                {
                    var manuMethodList = manuMethodSettingBLL.GetManuMethodList(new ManuMethodSettingSearchModel()
                    {
                        ManuId = info.ManuId,
                        Type = AgentPolicyTypes.OrderSend
                    });

                    var ap = new AgentPolicyBaseModel()
                    {
                        ManuId = info.ManuId,
                        UserId = info.UserId,
                        CustId = 0,
                        BussinessId = info.OrderId,
                    };

                    //: 执行代理商政策
                    AgentPolicyManager.Execute(manuMethodList, ap);
                }
            }
            return result;
        }

        /// <summary>
        /// 批量发货(快递鸟)
        /// </summary>
        public string BatchShipment(int manuId, int[] ids)
        {
            return orderMiFeiDAL.BatchShipment(manuId, ids);
        }
        /// <summary>
        /// 批量审核（提货单）
        /// </summary>
        public StringReturn BatchOrderAudit(int manuId, int[] ids)
        {
            StringReturn stringRet = new StringReturn();
            for (int i = 0; i < ids.Length; i++)
            {
                OrderEditSearchModel search = new OrderEditSearchModel();
                search.Status = 4;
                search.OrderId = ids[i].ToInt32();
                search.ManuId = manuId;
                stringRet = new OrderAuditPickUpMiFeiBLL().OrderPickUpAudit(search);
                if (!stringRet.Result)
                    return stringRet;
            }
            return stringRet;
        }

        /// <summary>
        /// 导出订单
        /// </summary>
        public bool ExportOrder(OrderSearchMiFeiModel search)
        {
            search.Page = 1;
            search.RecPerPage = int.MaxValue;
            var orderlist = orderMiFeiDAL.GetOrderPurchaseGoods(search);

            foreach (var item in orderlist)
            {
                item.Address = item.Province + item.City + item.Area + item.Address;

                var details = orderDetailMiFeiDAL.GetOrderDetail(new OrderDetailMiFeiSearchModel()
                {
                    OrderId = item.OrderId
                });

                string strDetail = string.Empty;
                foreach (var detail in details)
                {
                    strDetail += detail.BussinessName + "-(数量:" + detail.Quantity + ") \n\r";
                }
                item.OrderDetailInfo = strDetail;
            }
            var dt = orderlist.ListGenuricConvertToDataTable();

            var field = "OrderNum,CustName,CustCatalogName,OrderTypeText,OrderDetailInfo,Address,Consignee,Phone,Quantity,Amount,PayPrice,StatusText,ExpressCompany,CourierNumber,CreateTime,Remark";
            var title = "订单号,下单人,代理级别,订单类型,订单商品明细,收货地址,收货人,手机号,总数量,总金额,付款金额,订单状态,快递类型,快递单号,下单时间,备注";
            if (search.OrderType == OrderTypeEnum.Purchase)
            {
                field = "OrderNum,CustName,CustCatalogName,OrderTypeText,OrderDetailInfo,CustPhone,Quantity,Amount,PayPrice,StatusText,CreateTime,Remark";
                title = "订单号,下单人,代理级别,订单类型,订单商品明细,手机号,总数量,总金额,付款金额,订单状态,下单时间,备注";
            }
            var msg = ExcelUtility.DataTableToExcel(dt, "/Export/MiFei/ExcelReport.xls", "/Export/MiFei/" + search.OrderType.GetEnumDescription() + "_" + DateTime.Now.ToString("yyyyMMdd") + ".xls", title, field);
            return msg;
        }

        /// <summary>
        /// 订单删除
        /// </summary>
        public StringReturn OrderDelete(int manuId, int userId, int orderId)
        {
            var sReturn = orderMiFeiDAL.OrderDelete(manuId, orderId);
            Log4Helper.LogInfo("OrderLogger", string.Format("100010(delete) => 厂家:{0},管理员:{1},删除订单Id:{2}, 结果:{3}", manuId, userId, orderId, JsonConvert.SerializeObject(sReturn)));
            return sReturn;
        }

        #region ## 导出发货单
        /// <summary>
        /// 导出
        /// </summary>
        public bool ExportSendOutOrder(OrderSearchMiFeiModel search)
        {
            search.Page = 1;
            search.RecPerPage = int.MaxValue;
            search.Status = OrderStatusEnum.AuditPassed;
            var dt = orderMiFeiDAL.GetOrderPurchaseGoods(search).ListGenuricConvertToDataTable();

            var field = "OrderNum,ExpressCompany,CourierNumber";
            var title = "订单号,快递公司,快递单号";
            var msg = ExcelUtility.DataTableToExcel(dt, "/Export/MiFei/ExcelReport.xls", "/Export/MiFei/发货单_" + DateTime.Now.ToString("yyyyMMdd") + ".xls", title, field);
            return msg;
        }

        /// <summary>
        /// 导入
        /// </summary>
        public StringReturn ExportSendInOrder(int manuId, int custId, HttpFileCollectionBase fileCollec)
        {
            var sReturn = new StringReturn();
            HttpPostedFileBase postedFile = fileCollec[0];

            // 生成文件夹
            var pathStr = SaveFileCommon.Instance.CreateDic("Export/" + manuId);
            pathStr = pathStr + "/" + GenerateHelper.Get16String() + postedFile.FileName;

            // 保存文件
            pathStr = SaveFileCommon.Instance.CreateFile(postedFile, pathStr);

            // 读取文件
            var table = ExcelUtility.ExcelToDataTable(pathStr, true);
            foreach (DataRow dRow in table.Rows)
            {
                // 订单号
                var OrderNum = (dRow[0] + "").Trim();
                // 物流公司
                var ExpressCompany = (dRow[1] + "").Trim();
                // 物流单号
                var CourierNumber = (dRow[2] + "").Trim();
                if (string.IsNullOrWhiteSpace(OrderNum) || string.IsNullOrWhiteSpace(ExpressCompany) || string.IsNullOrWhiteSpace(CourierNumber))
                {
                    continue;
                }

                var orderInfo = GetOrderByOrderNum(manuId, OrderNum);
                if (orderInfo.OrderId > 0)
                {
                    OrderSend(new OrderSendModel()
                    {
                        ManuId = manuId,
                        OrderId = orderInfo.OrderId,
                        ExpressCompany = ExpressCompany,
                        CourierNumber = CourierNumber
                    });
                }
            }

            return sReturn;
        }
        #endregion


        public int GetStateIdByOrderId(int orderId)
        {
            var custId = GetCustomerIdByOrderId(orderId);
            var stateId = GetAuditStateByCustId(custId);
            return stateId;
        }


        public int GetCustomerIdByOrderId(int orderId)
        {
            var custId = orderMiFeiDAL.GetCustomerIdByOrderId(orderId);
            return custId;
        }

        public int GetAuditStateByCustId(int custId)
        {
            var stateId = orderMiFeiDAL.GetAuditStateByCustId(custId);
            return stateId;
        }

    }
}