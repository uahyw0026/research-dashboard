using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using risdashboard.Models;
using DotNetCasClient;
using System.Diagnostics.Tracing;
using System.Diagnostics.Eventing;

namespace risdashboard.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            System.Security.Principal.IPrincipal p = HttpContext.User;

            string temp = p.ToString();

            string uid = p.Identity.Name; // uid is UAH A-Number

            if (uid != null)
            {
                try
                {
                    System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + "Login Success for " + uid);

                    UserModel user = new Models.UserModel(uid);
                    if (user.getUserInfo())
                    {
                        System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + "Role for " + uid + " is " + user.Roles.ToString());
                        Session.Remove("User");
                        Session.Add("User", user);

                        if (user.isPI())
                        {
                            System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + "Access Awards page -- " + uid);
                            return RedirectToAction("Home", "Awards");
                        }
                        else if (user.isDean() && !user.isAdmin())
                        {
                            System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + "Access Dean page -- " + uid);
                            return RedirectToAction("Index", "Dean");
                        }
                        else if (user.isAdmin())
                        {
                            System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + "Access Admin page -- " + uid);
                            return RedirectToAction("Index", "Admin");
                        }
                    }
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
            return RedirectToAction("LoginFailed", "Home");
        }
        public ActionResult Logout()
        {
            System.Security.Principal.IPrincipal p = HttpContext.User;
            string uid = p.Identity.Name;

            if (uid != null)
            {
                System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + uid + " Logout ");
                HttpContext.Session.Abandon();
                CasAuthentication.SingleSignOut();
            }
            return View();
        }

        public ActionResult About()
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
                    if (user.isPI() || user.isDean() || user.isAdmin())
                    {
                        ViewBag.Message = "About Research Dashboard website";
                        return View();
                    }
                    else
                    {
                        return RedirectToAction("Error", "Home", new { errormsg = "User authorization is failed to access Research Dashboard website" });
                    }
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }

        public ActionResult Contact()
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
                    if (user.isPI() || user.isDean() || user.isAdmin())
                    {
                        ViewBag.Message = "Contact with Research Dashboard";
                        return View();
                    }
                    else
                    {
                        return RedirectToAction("Error", "Home", new { errormsg = "User authorization is failed to access Research Dashboard website" });
                    }
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
        public ActionResult Help()
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
                    if (user.isPI() || user.isDean() || user.isAdmin())
                    {
                        ViewBag.Message = "Research Dashboard Help Page";
                        return View();
                    }
                    else
                    {
                        return RedirectToAction("Error", "Home", new { errormsg = "User authorization is failed to access Research Dashboard website" });
                    }
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Error", "Home", new { errormsg = ex.Message });
                }
            }
        }
        public ActionResult LoginFailed()
        {
            System.Security.Principal.IPrincipal p = HttpContext.User;
            string uid = p.Identity.Name;

            if (uid == null)
            {
                ViewBag.UserID = "";
                ViewBag.Message = "ID is not available.";
                System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + "ID is not available, Login failed ");
            }
            else
            {
                ViewBag.UserID = uid;
                ViewBag.Message = "login failed.";
                System.Diagnostics.Trace.TraceInformation(System.DateTime.Now.ToString() + "\t" + uid + " Login failed ");
            }
            return View();
        }
        public ActionResult Error(string errormsg)
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
                    if (user.isPI() || user.isDean() || user.isAdmin())
                    {
                        ViewBag.Message = errormsg;
                        System.Diagnostics.Debug.WriteLine(System.DateTime.Now.ToString() + "\t" + "Error for " + user.getUserName() + " -- " + errormsg);
                        return View();
                    }
                    else
                    {
                        string msg = "User authorization is failed to access Research Dashboard website";
                        ViewBag.Message = msg;
                        System.Diagnostics.Debug.WriteLine(System.DateTime.Now.ToString() + "\t" + "Error for " + user.getUserName() + " -- " + msg);
                        return View();
                    }
                }
                catch (Exception ex)
                {
                    ViewBag.Message = ex.Message;
                    System.Diagnostics.Debug.WriteLine(System.DateTime.Now.ToString() + "\t" + "Error -- " + ex.Message);
                    return View();
                }
            }
        }
    }
}