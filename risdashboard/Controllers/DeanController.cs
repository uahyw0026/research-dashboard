using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using risdashboard.Models;

namespace risdashboard.Controllers
{
    public class DeanController : Controller
    {
        // GET: Dean
        public ActionResult Index()
        {

            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    Models.UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    AwardViewModel award = new AwardViewModel(user);

                    // retrieve grant awards info from Banner
                    List<GrantModel> Awards = new List<GrantModel>();
                    Awards = award.BindAwards("", "2");
                    award.Awards = Awards;

                    // retrieve project ending with 120 days info from Banner
                    List<GrantEndsModel> AwardEnds = new List<GrantEndsModel>();
                    AwardEnds = award.BindAwardEnds("", "2");
                    award.AwardEnds = AwardEnds;

                    award.user.CurrentRole = "Dean";
                    return View(award);
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
    }
}