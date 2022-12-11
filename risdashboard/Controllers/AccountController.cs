using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;
using risdashboard.Models;

namespace risdashboard.Controllers
{
    public class AccountController : Controller
    {
        // GET: Account
       
        public ActionResult Index(string fund, string account, string transType)
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    AccountViewModel accountview = new AccountViewModel();
                    accountview.user = (Models.UserModel)HttpContext.Session["User"];
                    if (accountview.BindAccount(fund, account, transType))
                        return View(accountview);
                    else
                        return RedirectToAction("Error", "Home", new { errormsg = "Error for QUerying account " + account + " for fund " + fund });
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
    }
}