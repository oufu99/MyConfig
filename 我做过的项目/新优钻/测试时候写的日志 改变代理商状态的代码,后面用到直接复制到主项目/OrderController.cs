using MiFei.BLL;
using MiFei.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Ws.Common;
using WsBg.Web.Common;

namespace MiFei.Controllers
{
    public class OrderController : BaseController
    {
        private OrderMiFeiBLL orderMiFeiBLL = new OrderMiFeiBLL();

        /// <summary>
        /// 订单详情
        /// </summary>
        public JsonResult GetOrderDetail(OrderEditSearchModel search)
        {
            var data = orderMiFeiBLL.GetOrderDetail(search);
            return AjaxResult(data);
        }

        /// <summary>
        /// 订单审核
        /// </summary>
        public JsonResult PostOrderAudit(OrderEditSearchModel search)
        {
            Log4Helper.LogInfo("GlobalLogger", "youzuan审核订单前 =>  stateId:" + orderMiFeiBLL.GetStateIdByOrderId(search.OrderId) + "custId:" + search.CustId);
            var mReturn = orderMiFeiBLL.PostOrderAudit(search);
            if (!mReturn.Result)
                return AjaxResult(mReturn, 0, mReturn.Msg);
            Log4Helper.LogInfo("GlobalLogger", "youzuan审核订单后 =>  stateId:" + orderMiFeiBLL.GetStateIdByOrderId(search.OrderId) + "custId:" + search.CustId);
            return AjaxResult(mReturn, msg: "审核成功");
        }

        /// <summary>
        /// 批量发货(快递鸟)
        /// </summary>
        public JsonResult BatchShipment(int[] ids)
        {
            string returnRst = orderMiFeiBLL.BatchShipment(this.BaseModel.ManuId, ids);
            if (returnRst == true.ToString())
                return AjaxResult("", 1, "发货成功！");
            else
                return AjaxResult("", 0, returnRst);
        }

        /// <summary>
        /// 补货订单导出
        /// </summary>
        public JsonResult ExportPurchaseOrder(OrderSearchMiFeiModel search)
        {
            search.OrderType = OrderTypeEnum.Purchase;
            bool returnRst = orderMiFeiBLL.ExportOrder(search);
            if (returnRst)
                return AjaxResult("", 1, "导出成功！");
            else
                return AjaxResult("", 0, "导出失败！");
        }

        /// <summary>
        /// 直购订单导出
        /// </summary>
        public JsonResult ExportDirectOrder(OrderSearchMiFeiModel search)
        {
            search.OrderType = OrderTypeEnum.DirectPurchase;
            bool returnRst = orderMiFeiBLL.ExportOrder(search);
            if (returnRst)
                return AjaxResult("", 1, "导出成功！");
            else
                return AjaxResult("", 0, "导出失败！");
        }

        /// <summary>
        /// 提货订单导出
        /// </summary>
        public JsonResult ExportPickUpOrder(OrderSearchMiFeiModel search)
        {
            search.OrderType = OrderTypeEnum.PickUpGoods;
            bool returnRst = orderMiFeiBLL.ExportOrder(search);
            if (returnRst)
                return AjaxResult("", 1, "导出成功！");
            else
                return AjaxResult("", 0, "导出失败！");
        }

        /// <summary>
        /// 导出发货单
        /// </summary>
        public JsonResult ExportSendOutOrder(OrderSearchMiFeiModel search)
        {
            search.OrderType = OrderTypeEnum.PickUpGoods;
            bool returnRst = orderMiFeiBLL.ExportSendOutOrder(search);
            if (returnRst)
                return AjaxResult("", 1, "导出成功！");
            else
                return AjaxResult("", 0, "导出失败！");
        }

        /// <summary>
        /// 导入发货单
        /// </summary>
        public JsonResult ExportSendInOrder()
        {
            var sReturn = orderMiFeiBLL.ExportSendInOrder(this.BaseModel.ManuId, this.BaseModel.CustId, Request.Files);
            if (!sReturn.Result)
                return AjaxResult(sReturn, 0, "导入发货失败！");
            return AjaxResult(sReturn, 1, "导入发货成功！");
        }

        /// <summary>
        /// 填写物流信息发货
        /// </summary>
        public JsonResult OrderSend(int orderId, string expressCompany, string courierNumber)
        {
            OrderMiFeiBLL orderBLL = new OrderMiFeiBLL();
            var returnRst = orderBLL.OrderSend(new OrderSendModel()
            {
                ManuId = this.BaseModel.ManuId,
                UserId = this.BaseModel.UserId,
                OrderId = orderId,
                ExpressCompany = expressCompany,
                CourierNumber = courierNumber
            });
            if (returnRst)
                return AjaxResult("", msg: "发货成功！");
            else
                return AjaxResult("", 0, "发货失败！");
        }
    }
}