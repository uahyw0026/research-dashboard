using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using risdashboard.Models;

namespace risdashboard.Controllers
{
    public class FundsController : Controller
    {
        // GET: Funds
        public ActionResult Index(string fund, string detail)
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    FundViewModel fundview = new FundViewModel();
                    fundview.user = (Models.UserModel)HttpContext.Session["User"];
                    if (fundview.BindFunds(fund, detail))
                        return View(fundview);
                    else
                        return RedirectToAction("Error", "Home", new { errormsg = "Error for QUerying fund info for fund " + fund });
                }
                catch(Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }    
        }
    }
}