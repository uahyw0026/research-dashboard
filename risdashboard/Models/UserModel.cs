using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Configuration;

namespace risdashboard.Models
{
    public class UserModel
    {
        public string pidm { get; set; }
        public string MyBamaID { get; set; } // myBama ID is UAH A-Number
        public string Roles { get; set; }
        public string CurrentRole { get; set; }
        public string CurrentAdminAction { get; set; }
        string FirstName;
        string MiddleName;
        string LastName;
        string Email;
        public string CurrentFund;     //current viewing fund ID
        public string CurrentAccount;  //current viewing account
        

        public UserModel()
        { MyBamaID = ""; Roles = ""; }

        public UserModel(string ID)
        {
            string runningenv = ConfigurationManager.AppSettings["RunningEnv"].ToString();

            MyBamaID = ID; 
            if(runningenv == "LOCAL" || runningenv == "TEST")
            {
                string pitestusers = ConfigurationManager.AppSettings["PITestingUsers"].ToString();
                string pitest = ConfigurationManager.AppSettings["PITesting"].ToString();
                MyBamaID = pitestusers.Contains(MyBamaID) ? pitest : MyBamaID;
            }
            Roles = ""; 
            CurrentRole = ""; 
        }

        public UserModel(string ID, string curRole)
        { MyBamaID = ID; Roles = ""; CurrentRole = curRole; }

        public UserModel(string v_pidm, string v_mybamaid, string v_firstname, string v_middlename, string v_lastname, string v_email)
        {
            pidm = v_pidm;
            MyBamaID = v_mybamaid;
            FirstName = v_firstname;
            MiddleName = v_middlename;
            LastName = v_lastname;
            Email = v_email;
        }

        public bool getUserInfo()
        {
            bool result = false;
            string QueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_user_auth";

            DatabaseModel dm = new DatabaseModel();
            ProcParam param1 = new ProcParam("v_mybamaid", MyBamaID, "CHAR", "IN");
            ProcParam param2 = new ProcParam("p_user_data", null, "CURSOR", "OUT");

            dm.procParams.Add(param1);
            dm.procParams.Add(param2);

            try
            {
                bool cert_success = dm.getProcedureData(QueryString);
                if (cert_success)
                {
                    int v_count = dm.daResult.Tables[0].Rows.Count;
                    if (v_count == 0)
                    {
                        throw new Exception("User is not authorized to access Research Dashboard Application.");
                    }
                    else
                    {
                        foreach (DataRow dr in dm.daResult.Tables[0].Rows)
                        {
                            string r_role = dr["role"].ToString();

                            if (dr["role"].ToString() == "001")
                            {
                                Roles = Roles + "P,"; //PI
                            }
                            else if (dr["role"].ToString() == "SCHOOL")
                            {
                                Roles = Roles + "S,"; //Dean
                            }
                            else if (dr["role"].ToString() == "ADMIN")
                            {
                                Roles = Roles + "A,S,"; //Admin, Admin has to see school view
                            }

                            pidm = dr["pidm"].ToString();
                            FirstName = dr["firstname"].ToString();
                            LastName = dr["lastname"].ToString();
                        }
                        if (Roles != "")
                        {
                            Roles.TrimEnd(',');
                        }
                        result = true;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Error: {0}", e.Message);
            }
            return result;
        }
        public bool getUserInfo(Object sessionCurRole)
        {
            bool result = false;
            string QueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_user_auth";

            DatabaseModel dm = new DatabaseModel();
            ProcParam param1 = new ProcParam("v_mybamaid", MyBamaID, "CHAR", "IN");
            ProcParam param2 = new ProcParam("p_user_data", null, "CURSOR", "OUT");

            dm.procParams.Add(param1);
            dm.procParams.Add(param2);

            try
            {
                bool cert_success = dm.getProcedureData(QueryString);
                if (cert_success)
                {
                    int v_count = dm.daResult.Tables[0].Rows.Count;
                    if (v_count == 0)
                    {
                        throw new Exception("User is not authorized to access Research Dashboard Application.");
                    }
                    else
                    {
                        foreach (DataRow dr in dm.daResult.Tables[0].Rows)
                        {
                            string r_role = dr["role"].ToString();

                            if (dr["role"].ToString() == "001")
                            {
                                Roles = Roles + "P,"; //PI
                            }
                            else if (dr["role"].ToString() == "ADMIN")
                            {
                                Roles = Roles + "A,S,"; //Admin, Admin has to see school view
                            }
                            else if (dr["role"].ToString() == "SCHOOL")
                            {
                                Roles = Roles + "S,"; //Dean
                            }

                            pidm = dr["pidm"].ToString();
                            FirstName = dr["firstname"].ToString();
                            LastName = dr["lastname"].ToString();
                        }
                        if (Roles != "")
                        {
                            Roles.TrimEnd(',');
                        }
                        result = true;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Error: {0}", e.Message);
            }

            // validate current role has to be one of user roles
            if (Roles != "" && sessionCurRole != null)
            {
                CurrentRole = sessionCurRole.ToString();

                string[] t_roles = Roles.Split(',');
                if (CurrentRole != "" && !t_roles.Contains(CurrentRole)) result = false;
            }

            return result;
        }

        public bool isPI()
        {
            bool result = false;
           
            string[] t_roles = Roles.Split(',');
            result = t_roles.Contains("P");
            return result;
        }
        public bool isCoPI()
        {
            bool result = false;

            string[] t_roles = Roles.Split(',');
            result = t_roles.Contains("C");
            return result;
        }
        public bool isAdmin()
        {
            bool result = false;

            string[] t_roles = Roles.Split(',');
            result = t_roles.Contains("A");
            return result;
        }
        public bool isDeptAdmin()
        {
            bool result = false;

            string[] t_roles = Roles.Split(',');
            result = t_roles.Contains("D");
            return result;
        }
        public bool isDean()
        {
            bool result = false;

            string[] t_roles = Roles.Split(',');
            result = t_roles.Contains("S");
            return result;
        }

        public string getUserName()
        {
            return FirstName + " " + LastName;
        }
    }
}