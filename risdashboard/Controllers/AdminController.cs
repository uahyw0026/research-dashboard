using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Microsoft.Ajax.Utilities;
using risdashboard.Models;

namespace risdashboard.Controllers
{
    public class AdminController : Controller
    {
        // GET: Admin
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
                    UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    if (user.isAdmin())
                    {
                        AdminViewModel admin = new Models.AdminViewModel(user);
                        admin.user.CurrentRole = "Admin";

                        // retrieve school level user info
                        List<DeanModel> DeanUsers = new List<DeanModel>();
                        DeanUsers = admin.BindSchoolUsers();
                        admin.Deans = DeanUsers;

                        return View(admin);
                    }
                    else
                        return RedirectToAction("Index", "Home");
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
        public ActionResult DeanUserCreate()
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    if (user.isAdmin())
                    {
                        AdminViewModel admin = new Models.AdminViewModel(user);
                        admin.NewDean = new NewDeanModel();
                        admin.BindOrgns();
                        admin.user.CurrentRole = "Admin";

                        return View("Index", admin);
                    }
                    else
                        return RedirectToAction("Index", "Home");
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
        [HttpPost]
        public ActionResult DeanUserCreate(AdminViewModel admin)
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                if (!ModelState.IsValid)
                    return RedirectToAction("Error", "Home", new { errormsg = "Invalid Input for Creating School Level Users!" });

                try
                {
                    UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    if (user.isAdmin())
                    {
                        // insert new dean user to map table
                        if(!(admin.NewDean == null))
                        {
                            admin.user = user;
                            bool status = admin.InsertNewDeanUser();
                            if (status)
                            {
                                admin.NewDean = null;
                                ViewBag.Message = "Insert User success!";
                            }
                            else
                            {
                                ViewBag.Message = "Error -- Insert User Failed!";
                            }
                        }
                        else
                        {
                            ViewBag.Message = "User Data Error, please enter data for user creation.";
                        }
                        // retrieve school level user info
                        List<DeanModel> DeanUsers = new List<DeanModel>();
                        DeanUsers = admin.BindSchoolUsers();
                        admin.Deans = DeanUsers;
                        admin.user.CurrentRole = "Admin";

                        return View("Index", admin);
                    }
                    else
                        return RedirectToAction("Index", "Home");
                }
                catch (Exception ex)
                {
                    ViewBag.Message = ex.Message;
                    return View("Index", admin);
                }
            }
        }
        public ActionResult DeanUserdelete(string pidm, string orgn)
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    if (user.isAdmin())
                    {
                        AdminViewModel admin = new Models.AdminViewModel(user);

                        // delete dean user from map table
                        bool status = admin.DeleteDeanUser(pidm, orgn);
                        if (status) 
                        {
                            ViewBag.Message = "Delete User success!";
                        }
                        else
                        {
                            ViewBag.Message = "ERROR -- Delete User failed!";
                        }

                        // retrieve school level user info
                        List<DeanModel> DeanUsers = new List<DeanModel>();
                        DeanUsers = admin.BindSchoolUsers();
                        admin.Deans = DeanUsers;
                        admin.user.CurrentRole = "Admin";

                        return View("Index", admin);
                    }
                    else
                        return RedirectToAction("Index", "Home"); 
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
        public ActionResult MVRefreshStatus()
        {
            if (HttpContext.Session["User"] == null)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    if (user.isAdmin())
                    {
                        AdminViewModel admin = new Models.AdminViewModel(user);

                        // delete dean user from map table
                        bool status = admin.BindMVStatus();
                        if (!status)
                        {
                            ViewBag.Message = "ERROR -- Can not get Materialized View Refresh Information!";
                        }
                        admin.user.CurrentRole = "Admin";

                        return View("Index", admin);
                    }
                    else
                        return RedirectToAction("Index", "Home");
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
        public JsonResult GetUserName(string cwid)
        {
            List<String> stringArr = new List<String>();
            if (HttpContext.Session["User"] == null)
            {
                return null;
            }
            else
            {
                try
                {
                    UserModel user = (Models.UserModel)HttpContext.Session["User"];
                    if (user.isAdmin())
                    {
                        AdminViewModel admin = new Models.AdminViewModel(user);
                        bool status = admin.BindNewDeanUser(cwid);

                        if (status)
                        {
                            return Json(admin.NewDean, JsonRequestBehavior.AllowGet);
                        }
                    }
                }
                catch (Exception ex)
                {
                    return null;
                }
            }
            return null;               
        }
    }
}