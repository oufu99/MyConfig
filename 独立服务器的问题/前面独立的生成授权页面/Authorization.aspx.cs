using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Authorization : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string templateid = Request.Form["templateid"];
        string customerID = Request.Form["customerID"];
        string authorizeID = Request.Form["authorizeID"];
        string manuID = Request.Form["manuID"];
        object[] obj = new object[] { templateid, customerID, authorizeID, manuID };
        Response.Write(AddAuthorization(obj));
        Response.End();
    }

    public static string AddAuthorization(object[] array)
    {
        try
        {
            Customer omer = new Customer();
            string CustID = array[3].ToString();
            string Imgurl = "";
            SERP3.Common.Log4Helper.LogInfo("生成授权111"  , "AliPay");
            //隐私设置获取
            Dictionary<string, string> dicsetting = new Dictionary<string, string>();
            string sql = "select [key],value from tb_setting where is_active=1  and setting_catalog_code='privatesetting' and manufacturer_id=" + CustID;
            DataSet ds = SQL.GetDataSet(sql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow dr in ds.Tables[0].Rows)
                {
                    dicsetting.Add(dr["key"].ToString(), dr["value"].ToString());
                }
            }

            //模板背景图上
            sql = "select template_imgurl from tb_license_template where tb_license_templateid=" + array[0].ToString();
            ds = SQL.GetDataSet(sql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                DataRow Row = ds.Tables[0].Rows[0];
                Imgurl = Row["template_imgurl"].ToString();
            }
            
            var image = System.Drawing.Image.FromFile(System.Web.HttpContext.Current.Server.MapPath("/img"+Imgurl));
            var g = Graphics.FromImage(image);
            g.DrawImage(image, 0, 0, image.Width, image.Height);
            var f = new Font("Verdana", 8);
            var q = new Font("Verdana", 6);
            Brush b = new SolidBrush(Color.Black);
            sql = "select * from tb_customer_" + CustID + " where tb_customerID=" + array[1].ToString();
            ds = SQL.GetDataSet(sql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                DataRow Row = ds.Tables[0].Rows[0];
                omer.CustName = Row["name"].ToString();
                omer.UserName = Row["contact"].ToString();
                omer.AuthCodes = Row["authorize_code"].ToString();
                omer.Mobiles = encodemobile(Row["mobile"].ToString(), dicsetting["tel"].ToString());
                omer.Wechats = encodemobile(Row["weixi_no"].ToString(), dicsetting["weixin"].ToString());
                omer.IdNos = encodeid(Row["id_card"].ToString(), dicsetting["cardId"].ToString());
            }
            sql = "select (CASE WHEN brand_id = 0 THEN '全部品牌' ELSE dbo.S_BrandName_BrandID(brand_id) END) as BrandName,(CASE WHEN porduct_catalog_id = 0 THEN '全部系列' ELSE dbo.S_AuthBrand_BrandID(porduct_catalog_id) END) as AuthClass1,(CASE WHEN product_catalog_children_id = '0' THEN '全部系列' ELSE dbo.GetProductCatalogChildrenName(','+product_catalog_children_id+',') END) as AuthClass2,dbo.S_AuthorizeLevel_BrandID(agent_authorize_level_id) as AuthKind,convert(varchar(100),begin_time,23) as begin_time,convert(varchar(100),end_time,23) as end_time from tb_agent_authorize_" + CustID + " where tb_agent_authorizeID=" + array[2].ToString();
            ds = SQL.GetDataSet(sql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                DataRow Row = ds.Tables[0].Rows[0];
                omer.AuthKinds = Row["AuthKind"].ToString();
                omer.AuthBrands = Row["BrandName"].ToString();
                omer.AuthClasss1 = Row["AuthClass1"].ToString();
                omer.AuthClasss2 = Row["AuthClass2"].ToString();
                omer.BeginDates = Row["begin_time"].ToString();
                omer.EndDates = Row["end_time"].ToString();
                omer.BeginYears = Convert.ToDateTime(Row["begin_time"].ToString()).ToString("yyyy");
                omer.BeginMonths = Convert.ToDateTime(Row["begin_time"].ToString()).ToString("MM");
                omer.BeginDays = Convert.ToDateTime(Row["begin_time"].ToString()).ToString("dd");
                omer.EndYears = Convert.ToDateTime(Row["end_time"].ToString()).ToString("yyyy");
                omer.EndMonths = Convert.ToDateTime(Row["end_time"].ToString()).ToString("MM");
                omer.EndDay = Convert.ToDateTime(Row["end_time"].ToString()).ToString("dd");
            }
            string MyJison = "";
            sql = "select template_content from tb_license_template where tb_license_templateid=" + array[0].ToString();
            ds = SQL.GetDataSet(sql);
            if (ds.Tables[0].Rows.Count > 0)
            {
                Font size = null;
                DataRow Row = ds.Tables[0].Rows[0];
                MyJison = Row["template_content"].ToString();
                var MyJson = JArray.Parse(MyJison);
                var AuthCode = MyJson[0]["AuthCode"];
                if (AuthCode != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(AuthCode["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(AuthCode["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");
                    var NameLeft = MyName.left.Replace("px", "");
                    var FontColor = MyStyle.FontColor;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var FontFamily = MyStyle.FontFamily;
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);

                    g.DrawString(omer.AuthCodes, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var Name = MyJson[0]["Name"];
                if (Name != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(Name["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(Name["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");
                    var NameLeft = MyName.left.Replace("px", "");
                    var FontColor = MyStyle.FontColor;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var FontFamily = MyStyle.FontFamily;
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);

                    g.DrawString(omer.UserName, f, b, TryFloat(NameLeft, 1), TryFloat(NameTop, 1));
                }
                /*var Name1 = MyJson[0]["Name_01"];
                if (Name1 != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(Name1["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(Name1["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");
                    var NameLeft = MyName.left.Replace("px", "");
                    var FontColor = MyStyle.FontColor;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font("Verdana", Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);

                    g.DrawString(omer.UserName, f, b, TryFloat(NameLeft, 1), TryFloat(NameTop, 1));
                }*/
                var Mobile = MyJson[0]["Mobile"];
                if (Mobile != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(Mobile["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(Mobile["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.Mobiles, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var Wechat = MyJson[0]["Wechat"];
                if (Wechat != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(Wechat["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(Wechat["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.Wechats, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var IdNo = MyJson[0]["IdNo"];
                if (IdNo != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(IdNo["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(IdNo["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.IdNos, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var AuthKind = MyJson[0]["AuthKind"];
                if (AuthKind != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(AuthKind["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(AuthKind["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    
                    StringFormat format = new StringFormat(StringFormatFlags.DirectionRightToLeft);
                    format.Alignment = StringAlignment.Center;
                    
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    
                    if (CustID == "10021") //- 优源授权级别居中处理
                        g.DrawString(omer.AuthKinds, f, b, TryFloat(NameLeft, 0) + 30, TryFloat(NameTop, 0), format);
                    else
                        g.DrawString(omer.AuthKinds, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var AuthBrand = MyJson[0]["AuthBrand"];
                if (AuthBrand != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(AuthBrand["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(AuthBrand["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var FontFamily = MyStyle.FontFamily;
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.AuthBrands, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var AuthClass1 = MyJson[0]["AuthClass1"];
                if (AuthClass1 != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(AuthClass1["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(AuthClass1["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.AuthClasss1, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var AuthClass2 = MyJson[0]["AuthClass2"];
                if (AuthClass2 != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(AuthClass2["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(AuthClass2["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.AuthClasss2, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var BeginDate = MyJson[0]["BeginDate"];
                if (BeginDate != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(BeginDate["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(BeginDate["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.BeginDates, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var EndDate = MyJson[0]["EndDate"];
                if (EndDate != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(EndDate["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(EndDate["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.EndDates, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var BeginYear = MyJson[0]["BeginYear"];
                if (BeginYear != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(BeginYear["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(BeginYear["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.BeginYears, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var BeginMonth = MyJson[0]["BeginMonth"];
                if (BeginMonth != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(BeginMonth["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(BeginMonth["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.BeginMonths, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var BeginDay = MyJson[0]["BeginDay"];
                if (BeginDay != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(BeginDay["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(BeginDay["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.BeginDays, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var EndYear = MyJson[0]["EndYear"];
                if (EndYear != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(EndYear["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(EndYear["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.EndYears, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var EndMonth = MyJson[0]["EndMonth"];
                if (EndMonth != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(EndMonth["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(EndMonth["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.EndMonths, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                var EndDay = MyJson[0]["EndDay"];
                if (EndDay != null)
                {
                    var MyName = JsonConvert.DeserializeObject<Temp>(EndDay["POSITION"].ToString());
                    var MyStyle = JsonConvert.DeserializeObject<Temp>(EndDay["STYLE"].ToString());
                    var NameTop = MyName.top.Replace("px", "");             //X
                    var NameLeft = MyName.left.Replace("px", "");           //Y
                    var FontColor = MyStyle.FontColor;
                    var FontFamily = MyStyle.FontFamily;
                    var FontSize = MyStyle.FontSize.Replace("px", "");
                    var UnderLine = MyStyle.UnderLine.ToString() == "underline" ? FontStyle.Underline : FontStyle.Regular;
                    string[] FontSizes = FontSize.Split('.');
                    //渲染字体的颜色
                    b = new SolidBrush(ColorTranslator.FromHtml(MyStyle.FontColor));
                    f = new Font(FontFamily, Convert.ToInt32(FontSizes[0]), UnderLine, GraphicsUnit.Pixel);
                    g.DrawString(omer.EndDay, f, b, TryFloat(NameLeft, 0), TryFloat(NameTop, 0));
                }
                g.Dispose();
                // "/Upload_S/U_IMG/img_1/1_20160509/zp201605091448310819312041000.jpg"
                string directory = "/img/fwcert/cert_" + CustID;
                string ImgName = directory + "/" + Convert.ToDateTime(DateTime.Now).ToString("yyyyMMddssmm") + "_" + CustID + "_" + array[1].ToString() + "_new.jpg";
                if (!System.IO.Directory.Exists(System.Web.HttpContext.Current.Server.MapPath(directory)))
                    System.IO.Directory.CreateDirectory(System.Web.HttpContext.Current.Server.MapPath(directory));
                var path = System.Web.HttpContext.Current.Server.MapPath(ImgName);
                image.Save(path);
                SERP3.Common.Log4Helper.LogInfo("生成授权path"+ path, "AliPay");
                image.Dispose();
                //path = path.Replace("/img/","/");
                sql = "update tb_agent_authorize_" + CustID + " set Template=" + array[0].ToString() + ",Cert='" + ImgName+ "' where tb_agent_authorizeID=" + array[2].ToString();
                int a = SQL.ExecuteSql(sql);
                //return "成功";
                //object[] obj = new object[] { templateid, customerID, authorizeID, manuID };
                Pro.RunPro("tb_license_log_INSERT", new object[] { 
            "templateid:"+array[0]+",customerID:"+array[1]+",authorizeID:"+array[2]+",manuID:"+array[3]+",rowcount:"+a,"getcert"
        });
                return "1";
            }
            else
            {
                //return "请设置模板后重试";
                Pro.RunPro("tb_license_log_INSERT", new object[] { "err:没有找到模板", "getcert" });
                return "0";
            }
        }
        catch (Exception ex)
        {
            //return "失败";
            Pro.RunPro("tb_license_log_INSERT", new object[] { "err:" + ex.ToString(), "getcert" });
            return ex.ToString();
        }
    }

    #region 替换身份证中间8位为*
    private static string encodeid(string idno, string kind)
    {
        string IdNos = string.Empty;
        if (kind == "2")
        {
            int length = idno.Length;
            if (length > 6)
            {
                for (int i = 0; i < length; i++)
                {
                    if (i > 5 && i < 14)
                        IdNos += "*";
                    else IdNos += idno[i];
                }
            }
        }
        else
            IdNos = idno;
        return IdNos;
    }
    #endregion

    #region 替换手机号/微信号中间6位为*
    private static string encodemobile(string mobile, string kind)
    {
        string result = string.Empty;
        if (kind == "2")
        {
            int length = mobile.Length;
            if (length > 7)
            {
                for (int i = 0; i < length; i++)
                {
                    if (i > 2 && i < 7)
                        result += "*";
                    else result += mobile[i];
                }
            }
            else
                result = mobile;
        }
        else
            result = mobile;
        return result;
    }
    #endregion

    private static float TryFloat(string s, float defaultVal)
    {
        float val;
        if (float.TryParse(s, out val))
        {
            return val;
        }

        return defaultVal;
    }

    internal class Customer
    {
        /// <summary>
        /// 公司名称
        /// </summary>
        public string CustName { get; set; }            //公司名称
        /// <summary>
        /// 联系人
        /// </summary>
        public string UserName { get; set; }            //联系人
        /// <summary>
        /// 授权码
        /// </summary>
        public string AuthCodes { get; set; }           //授权码
        /// <summary>
        /// 手机号
        /// </summary>
        public string Mobiles { get; set; }             //手机号
        /// <summary>
        /// 微信号
        /// </summary>
        public string Wechats { get; set; }             //微信号
        /// <summary>
        /// 身份证号
        /// </summary>
        public string IdNos { get; set; }               //身份证号
        /// <summary>
        /// 授权级别
        /// </summary>
        public string AuthKinds { get; set; }           //授权级别
        /// <summary>
        /// 授权品牌
        /// </summary>
        public string AuthBrands { get; set; }          //授权品牌
        /// <summary>
        /// 授权类别-一级分类
        /// </summary>
        public string AuthClasss1 { get; set; }         //授权类别-一级分类
        /// <summary>
        /// 授权类别-二级分类
        /// </summary>
        public string AuthClasss2 { get; set; }         //授权类别-二级分类
        /// <summary>
        /// 授权开始日期
        /// </summary>
        public string BeginDates { get; set; }          //授权开始日期
        /// <summary>
        /// 授权结束日期
        /// </summary>
        public string EndDates { get; set; }            //授权结束日期
        /// <summary>
        /// 授权开始-年份
        /// </summary>
        public string BeginYears { get; set; }          //授权开始-年份
        /// <summary>
        /// 授权开始-月份
        /// </summary>
        public string BeginMonths { get; set; }         //授权开始-月份
        /// <summary>
        /// 授权开始-日
        /// </summary>
        public string BeginDays { get; set; }           //授权开始-日
        /// <summary>
        /// 授权结束-年份
        /// </summary>
        public string EndYears { get; set; }            //授权结束-年份
        /// <summary>
        /// 授权结束-月份
        /// </summary>
        public string EndMonths { get; set; }           //授权结束-月份
        /// <summary>
        /// 授权结束-日
        /// </summary>
        public string EndDay { get; set; }              //授权结束-日
    }

    internal class Temp
    {
        public string left { get; set; }
        public string top { get; set; }
        public string FontColor { get; set; }
        public string FontSize { get; set; }
        public string UnderLine { get; set; }
        public string FontFamily { get; set; }
    }
}