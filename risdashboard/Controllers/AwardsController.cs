using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using risdashboard.Models;

namespace risdashboard.Controllers
{
    public class AwardsController : Controller
    {
        // GET: Awards
        public ActionResult Index()
        {
            return View();
        }

        [Route("Awards/Home", Name = "PIAwards")]
        public ActionResult Home()
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    AwardViewModel award = new Models.AwardViewModel();
                    award.user = (Models.UserModel)HttpContext.Session["User"];

                    // retrieve proposal info
                    
                    award.BindProposals();

                    // retrieve grant awards info from Banner
                    List<GrantModel> Awards = new List<GrantModel>();
                    Awards = award.BindAwards("1", "1");
                    award.Awards = Awards;

                    // retrieve project ending with 120 days info from Banner
                   // List<GrantEndsModel> AwardEnds = new List<GrantEndsModel>();
                    //AwardEnds = award.BindAwardEnds("1", "1");
                    //award.AwardEnds = AwardEnds;

                    award.user.CurrentRole = "PI";
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