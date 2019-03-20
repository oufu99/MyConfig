using DbModels;
using ExpressQuery;
using ExpressQuery.Model;
using MiFei.Model;
using Newtonsoft.Json.Linq;
using PersonalCenter;
using PersonalCenter.Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Transactions;
using Ws.Common;
using WsBg.Common;
using WsBg.Web.Common;
using WsBg.Web.DAL;

namespace MiFei.DAL
{
    public class OrderMiFeiDAL
    {
        private StockManageDAL stockManageDAL = new StockManageDAL();

        /// <summary>
        /// 订单审核 列表
        /// </summary>
        public List<OrderMiFeiInfoResult> GetOrderPurchaseGoods(OrderSearchMiFeiModel search)
        {
            using (var context = new WsContext())
            {
                var query = from o in context.Order
                            join c in context.Customers
                                on o.CustId equals c.CustomerId into clist
                            from c in clist.DefaultIfEmpty()
                            join cc in context.CustomerCatalog
                                on o.CustomerCatalogId equals cc.CustomerCatalogId into cclist
                            from cc in cclist.DefaultIfEmpty()
                            where o.ManuId == search.ManuId && o.IsActive == true
                            select new OrderMiFeiInfoResult()
                            {
                                OrderId = o.Id,
                                OrderNum = o.OrderNum,
                                Status = o.Status,
                                Amount = o.Amount,
                                OrderAmount = o.OrderAmount,// 订单总金额
                                PayType = o.PayType, // 支付类型
                                Quantity = o.Quantity,
                                CreateTime = o.CreateTime,
                                PayPrice = o.PayPrice,// 支付金额
                                PayTime = o.PayTime,
                                Freight = o.Freight,// 运费
                                OrderType = o.OrderType,// 订单类型
                                CustName = c.Name ?? "",// 下单人
                                CustPhone = c.Mobile,
                                CustCatalogName = cc.Name ?? "",// 下单人级别
                                TargetId = o.TargetId,// 拿货上级Id
                                Consignee = o.Consignee,
                                Phone = o.Phone,
                                Province = o.Province,
                                City = o.City,
                                Area = o.Area,
                                Address = o.Address,
                                ExpressCompany = o.ExpressCompany,
                                CourierNumber = o.CourierNumber,//快递单号
                                IsCancel = o.IsCancel,
                                TrackCompany = o.TrackCompany, // 公司类型
                                Remark = o.Remark,    // 说明
                            };

                // 条件查询
                query = GetOrderPurchaseGoodsWhere(query, search);

                search.TotalCount = query.Count();
                return query.OrderByDescending(c => c.OrderId).Skip((search.Page - 1) * search.RecPerPage).Take(search.RecPerPage).ToList();
            }
        }

        /// <summary>
        /// 订单审核 列表 条件查询
        /// </summary>
        public IQueryable<OrderMiFeiInfoResult> GetOrderPurchaseGoodsWhere(IQueryable<OrderMiFeiInfoResult> query, OrderSearchMiFeiModel search)
        {
            if ((int)search.Status != 0)
            {
                if ((int)search.Status == -1)
                {
                    //订单已取消
                    query = query.Where(c => c.IsCancel == 1);
                }
                else
                {
                    // 订单状态
                    var OrderStatus = new int[1] { (int)search.Status };
                    if (search.Status == OrderStatusEnum.AuditPassed || search.Status == OrderStatusEnum.PendingSend)
                    {
                        OrderStatus = new int[2] { (int)OrderStatusEnum.AuditPassed, (int)OrderStatusEnum.PendingSend };
                    }
                    query = query.Where(c => OrderStatus.Contains(c.Status));
                }
            }

            if (search.OrderType == OrderTypeEnum.DirectPurchase || search.OrderType == OrderTypeEnum.PickUpGoods)
            {
                // 订单类型
                var OrderType = (int)search.OrderType;
                query = query.Where(c => c.OrderType == OrderType);
            }
            else if (search.OrderType == OrderTypeEnum.Purchase)
            {
                int[] whereArr = new int[3] {
                    (int)OrderTypeEnum.FirstOrder,
                    (int)OrderTypeEnum.Purchase,
                    (int)OrderTypeEnum.UpgradeOrder };
                query = query.Where(c => whereArr.Contains(c.OrderType));
            }

            // 标签 // 厂家直购订单
            if (search.Target == 1)
                query = query.Where(c => c.TargetId == 0);

            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(c => c.CustName.Contains(search.Name));

            if (!string.IsNullOrWhiteSpace(search.OrderNum))
                query = query.Where(c => c.OrderNum.Contains(search.OrderNum));

            if (!string.IsNullOrWhiteSpace(search.StartTime) && Lib.IsDateTime(search.StartTime))
            {
                var stime = Convert.ToDateTime(search.StartTime);
                query = query.Where(c => c.CreateTime >= stime);
            }

            if (!string.IsNullOrWhiteSpace(search.EndTime) && Lib.IsDateTime(search.EndTime))
            {
                var etime = Convert.ToDateTime(search.EndTime).AddDays(1);
                query = query.Where(c => c.CreateTime < etime);
            }

            // 导出时使用
            if (!string.IsNullOrWhiteSpace(search.Ids))
            {
                var IdArr = search.Ids.ToIntArr(',');
                query = query.Where(c => IdArr.Contains(c.OrderId));
            }

            return query;
        }

        /// <summary>
        /// 订单信息
        /// </summary>
        public OrderMiFeiInfoResult GetOrderByOrderNum(int manuId, string orderNum)
        {
            using (var context = new WsContext())
            {
                var query = context.Order.FirstOrDefault(c => c.ManuId == manuId && c.OrderNum == orderNum);
                return ToConvert(query, "", "", "");
            }
        }

        /// <summary>
        /// 获取订单信息，用于发货
        /// </summary>
        public OrderMiFeiInfoResult GetOrderToExpressBird(int manuId, int orderId)
        {
            using (var context = new WsContext())
            {
                var query = context.Order.FirstOrDefault(c => c.ManuId == manuId && c.Id == orderId && c.IsActive == true);
                return ToConvert(query, null, null, null);
            }
        }

        /// <summary>
        /// 转换类型
        /// </summary>
        public OrderMiFeiInfoResult ToConvert(DbModels.Order order, string custName, string custPhone, string custCatalogName)
        {
            var orderInfo = new OrderMiFeiInfoResult();
            // 厂家
            orderInfo.ManuId = order.ManuId;
            // 代理商
            orderInfo.CustId = order.CustId;
            // 订单Id
            orderInfo.OrderId = order.Id;
            // 订单号
            orderInfo.OrderNum = order.OrderNum;
            // 状态
            orderInfo.Status = order.Status;
            // 订单金额
            orderInfo.Amount = order.Amount;
            // 订单总金额
            orderInfo.OrderAmount = order.OrderAmount;
            // 支付类型
            orderInfo.PayType = order.PayType;
            // 订单数量
            orderInfo.Quantity = order.Quantity;
            // 联系人
            orderInfo.Consignee = order.Consignee;
            // 联系电话
            orderInfo.Phone = order.Phone;
            // 备注
            orderInfo.Remark = order.Remark;
            // 下单时间
            orderInfo.CreateTime = order.CreateTime;
            // 支付金额
            orderInfo.PayPrice = order.PayPrice;
            // 支付时间
            orderInfo.PayTime = order.PayTime;
            // 快递公司
            orderInfo.ExpressCompany = order.ExpressCompany;
            // 快递号码
            orderInfo.CourierNumber = order.CourierNumber;
            // 发货时间
            orderInfo.SendTime = order.SendTime;
            // 是否取消
            orderInfo.IsCancel = order.IsCancel;
            // 取消时间
            orderInfo.CancelTime = order.CancelTime;
            // 运费
            orderInfo.Freight = order.Freight;
            // 追踪公司
            orderInfo.TrackCompany = order.TrackCompany;
            // 追踪编号
            orderInfo.TrackId = order.TrackId;
            // 省
            orderInfo.Province = order.Province;
            // 市
            orderInfo.City = order.City;
            // 区、县
            orderInfo.Area = order.Area;
            // 详细地址
            orderInfo.Address = order.Address;
            // 支付流水号
            orderInfo.PaySerialNumber = order.PaySerialNumber;
            // 订单类型
            orderInfo.OrderType = order.OrderType;
            // 代理商上级
            orderInfo.TargetId = order.TargetId;
            // 代理商级别
            orderInfo.CustomerCatalogId = order.CustomerCatalogId;
            // 下单人
            orderInfo.CustName = custName;
            // 下单电话
            orderInfo.CustPhone = custPhone;
            // 下单人级别
            orderInfo.CustCatalogName = custCatalogName;
            // 付款凭证
            orderInfo.PayCer = order.PayCer;
            return orderInfo;
        }

        /// <summary>
        /// 获取订单详情信息
        /// </summary>
        private List<GoodsInfoEntity> GetOrderDetailToExpressBird(int orderId)
        {
            using (var context = new WsContext())
            {
                var query = from a in context.OrderDetail
                            where a.OrderId == orderId
                            select new GoodsInfoEntity()
                            {
                                // 商品名称
                                Name = a.BussinessName,
                                // 商品数量
                                Quantity = a.Quantity,
                                // 商品价格
                                Price = a.Price,
                                // 商品重量
                                Weight = 0
                            };
                return query.ToList();
            }
        }

        /// <summary>
        /// 读取订单详情
        /// </summary>
        public OrderJoinDetailMiFeiInfoResult GetOrderDetail(OrderEditSearchModel search)
        {
            using (var context = new WsContext())
            {
                var query = (from o in context.Order
                             join c in context.Customers
                                 on o.CustId equals c.CustomerId into clist
                             from c in clist.DefaultIfEmpty()
                             join cc in context.CustomerCatalog
                                 on o.CustomerCatalogId equals cc.CustomerCatalogId into cclist
                             from cc in cclist.DefaultIfEmpty()
                             where o.ManuId == search.ManuId && o.Id == search.OrderId
                                 && o.IsActive == true
                             select new OrderMiFeiSelectModel
                             {
                                 Order = o,
                                 CustName = c.Name ?? "",
                                 CustPhone = c.Mobile ?? "",
                                 CustCatalogName = cc.Name ?? ""
                             }).FirstOrDefault();

                AutoMapper.Mapper.Initialize(x => x.CreateMap<OrderMiFeiInfoResult, OrderJoinDetailMiFeiInfoResult>());
                return AutoMapper.Mapper.Map<OrderJoinDetailMiFeiInfoResult>(ToConvert(query.Order, query.CustName, query.CustPhone, query.CustCatalogName));
            }
        }


        /// <summary>
        /// 已转订单,查询最原始订单id
        /// </summary>
        public int GetOriginalOrderId(OrderEditSearchModel search)
        {
            using (var context = new WsContext())
            {
                return context.OrderCopy.Where(c => c.ManuId == search.ManuId && c.NewOrderId == search.OrderId).Select(x => x.OriginalOrderId).First();

            }

        }

        /// <summary>
        /// 订单审核 => 2 - 更新订单状态
        /// </summary>
        public StringReturn PostOrderAuditUpdateStatus(WsContext context, DbModels.Order orderInfo, int status)
        {
            var sReturn = new StringReturn();
            // 更新状态
            orderInfo.Status = status;
            context.Entry(orderInfo).State = System.Data.Entity.EntityState.Modified;
            sReturn.Result = context.SaveChanges() > 0;
            if (!sReturn.Result)
            {
                sReturn.Result = false;
                sReturn.Msg = "审核失败,无法更新状态";
                return sReturn;
            }
            return sReturn;
        }

        /// <summary>
        /// 订单审核 => 3 - 审核不通过且为货款支付时 - 返回货款（包含补货、提货）
        /// </summary>
        public StringReturn PostOrderAuditBackAccountMoney(WsContext context, DbModels.Order orderModel)
        {
            var sReturn = new StringReturn();

            if (orderModel.Status != (int)OrderStatusEnum.AuditNotPassed)
                return sReturn;

            if (orderModel.PayPrice <= 0)
                return sReturn;

            // 币种类型
            var currencyTypes = string.Empty;

            // 货款支付返回货款
            if (orderModel.PayType == (int)OrderPayTypeEnum.GoodsPay)
            {
                currencyTypes = CurrencyTypes.Goodspay;
            }
            // 线上支付返佣金
            else if (orderModel.PayType == (int)OrderPayTypeEnum.Commission
                || orderModel.PayType == (int)OrderPayTypeEnum.WXH5Pay
                || orderModel.PayType == (int)OrderPayTypeEnum.WXPay
                || orderModel.PayType == (int)OrderPayTypeEnum.ZFBH5Pay
                || orderModel.PayType == (int)OrderPayTypeEnum.ZFBPay)
            {
                currencyTypes = CurrencyTypes.Commission;
            }

            if (!string.IsNullOrWhiteSpace(currencyTypes))
            {
                sReturn = (new PersonalCenterManage()).PersonalCenterIn(new PersonalCenterModel(SourceTypes.OrderChargebacks, currencyTypes, orderModel.Id, orderModel.PayPrice, orderModel.ManuId, orderModel.CustId));
                if (!sReturn.Result)
                {
                    sReturn.Result = false;
                    sReturn.Msg = "审核失败，" + sReturn.Msg;
                    return sReturn;
                }
            }

            return sReturn;
        }

        /// <summary>
        /// 批量发货(快递鸟)
        /// </summary>
        public string BatchShipment(int manuId, int[] ids)
        {
            var addressDAL = new AddressDAL();
            // 获取发货地址
            var AddressInfo = addressDAL.GetDefaultAddress(manuId);
            if (AddressInfo == null)
                return "请完善发货地址信息！";
            if (ids.Count() <= 0)
                return "请选择订单！";

            var ReturnStr = true.ToString();
            using (var context = new WsContext())
            {
                var expressParameter = context.ExpressParameter.Where(c => c.ManuId == manuId).FirstOrDefault();
                if (expressParameter == null || expressParameter.ID <= 0)
                    return "请检查接口配置";

                var expressBirdSetting = context.ExpressBirdSetting.FirstOrDefault(c => c.ManuId == manuId);
                if (expressBirdSetting == null || expressBirdSetting.Id <= 0)
                    return "请检查表配置";

                try
                {
                    foreach (int id in ids)
                    {
                        var model = new ExpressBridElectronicSheetQuery(null, null);

                        var query = context.Order.FirstOrDefault(c => c.ManuId == manuId && c.Id == id && c.IsActive == true);
                        var OrderInfo = ToConvert(query, null, null, null);

                        model.ManuId = manuId;
                        model.Key = expressParameter.Key;
                        model.EBusinessID = expressParameter.EBusinessId;
                        model.ShipperCode = expressBirdSetting.ShipperCode;
                        model.ExpType = expressBirdSetting.ExpType.ToString();
                        model.GoodsInfos = GetOrderDetailToExpressBird(id);
                        model.PayType = expressBirdSetting.PayType;//到付

                        // 收货地址
                        model.OrderCode = OrderInfo.OrderNum;
                        model.RName = OrderInfo.Consignee;
                        model.RMobile = OrderInfo.Phone;
                        model.RProvinceName = OrderInfo.Province;
                        model.RCityName = OrderInfo.City;
                        model.RExpAreaName = OrderInfo.Area;
                        model.RAddress = OrderInfo.Address;
                        //model.ShipperCode = OrderInfo.TrackId;
                        model.Remark = OrderInfo.Remark;

                        // 设置 发货地址
                        model.SName = AddressInfo.Name;
                        model.SMobile = AddressInfo.Mobile;
                        model.SProvinceName = AddressInfo.Province;
                        model.SCityName = AddressInfo.City;
                        model.SExpAreaName = AddressInfo.Area;
                        model.SAddress = AddressInfo.Detail;

                        var json = ExpressManage.ElectronicSheetQuery(model, expressBirdSetting.ExpressClass);
                        var info = JObject.Parse(json);
                        if (info["ResultCode"].ToString() == "100")
                        {
                            var OrderCode = info["Order"]["OrderCode"].ToString();//订单编号
                            var ShipperCode = info["Order"]["ShipperCode"].ToString();//快递公司编码
                            var LogisticCode = info["Order"]["LogisticCode"].ToString();//快递单号
                                                                                        // 修改订单信息
                            BatchShipmentUpdateStatus(context, manuId, OrderCode, ShipperCode, LogisticCode);
                        }
                        else
                        {
                            ReturnStr = info["Reason"].ToString();
                        }
                    }
                }
                catch (Exception ex)
                {
                    ReturnStr = "发生异常:" + ex.Message;
                }
            }
            return ReturnStr;
        }

        /// <summary>
        /// 修改订单信息
        /// </summary>
        public void BatchShipmentUpdateStatus(WsContext context, int manuId, string orderNum, string shipperCode, string courierNumber)
        {
            var orderInfo = context.Order.Where(c => c.ManuId == manuId && c.OrderNum == orderNum).FirstOrDefault();
            if (orderInfo == null)
                return;

            orderInfo.SendTime = DateTime.Now;
            orderInfo.ExpressCompany = shipperCode;
            orderInfo.CourierNumber = courierNumber;
            orderInfo.Status = (int)OrderStatusEnum.AlreadySend;
            context.Entry(orderInfo).State = EntityState.Modified;
            context.SaveChanges();
        }

        /// <summary>
        /// 订单删除
        /// </summary>
        public StringReturn OrderDelete(int manuId, int orderId)
        {
            var sReturn = new StringReturn();
            using (var context = new WsContext())
            {
                var order = context.Order.FirstOrDefault(c => c.ManuId == manuId && c.Id == orderId);
                order.IsActive = false;
                context.Entry(order).State = EntityState.Modified;
                sReturn.Result = context.SaveChanges() > 0;
                if (!sReturn.Result)
                    sReturn.Msg = "删除失败";
                return sReturn;
            }
        }

        /// <summary>
        /// 订单详情
        /// </summary>
        public OrderMiFeiInfoResult GetOrder(int manuId, int orderId)
        {
            using (var context = new WsContext())
            {
                var query = (from a in context.Order
                             where a.ManuId == manuId && a.Id == orderId && a.IsActive == true
                             select a).FirstOrDefault();
                return ToConvert(query, "", "", "");
            }
        }

        /// <summary>
        /// 是否已经转过订单
        /// </summary>
        public OrderCopy OrderIsCopy(OrderEditSearchModel search)
        {

            using (var context = new WsContext())
            {
                var orderCopy = context.OrderCopy.FirstOrDefault(c => c.ManuId == search.ManuId && c.NewOrderId == search.OrderId);
                return orderCopy ?? new OrderCopy();
            }

        }


        public int GetCustomerIdByOrderId(int orderId)
        {
            using (var ctx = new WsContext())
            {
                return ctx.Order.First(c => c.ManuId == 10052 && c.Id == orderId).CustId;
            }
        }

        public int GetAuditStateByCustId(int custId)
        {
            using (var ctx = new WsContext())
            {
                return ctx.Customers.First(c => c.ManuId == 10052 && c.CustomerId == custId).AuditStatus;
            }
        }
    }
}