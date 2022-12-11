using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using risdashboard.Models;

namespace risdashboard.Models
{
    public class DeanViewModel // DeanView model is not used for UAH Research Dashboard
    {
        
        public UserModel user { get; set; }
        public List<GrantModel> SchoolAawrds { get; set; }
        public List<GrantEndsModel> SchoolEndAwards { get; set; }

        public DeanViewModel()
        {
            SchoolAawrds = new List<GrantModel>();
            SchoolEndAwards = new List<GrantEndsModel>();
        }
        public DeanViewModel(UserModel v_user)
        {
            SchoolAawrds = new List<GrantModel>();
            SchoolEndAwards = new List<GrantEndsModel>();
            user = v_user;
        }

        public List<GrantModel> BindAwards(string orgcode, string view)
        {
            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }
            string awardsQueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_awards";
            List<GrantModel> Awards = new List<GrantModel>();

            DatabaseModel dm_awards = new DatabaseModel();
            ProcParam param1 = new ProcParam("v_pidm", user.pidm, "CHAR", "IN");
            ProcParam param2 = new ProcParam("v_view", view, "CHAR", "IN");  // testing for PI
            ProcParam param3 = new ProcParam("v_org", orgcode, "CHAR", "IN");  // testing for PI
            ProcParam param4 = new ProcParam("v_source", "1", "CHAR", "IN");  // testing for PI
            ProcParam param5 = new ProcParam("p_awards", null, "CURSOR", "OUT");

            dm_awards.procParams.Add(param1);
            dm_awards.procParams.Add(param2);
            dm_awards.procParams.Add(param3);
            dm_awards.procParams.Add(param4);
            dm_awards.procParams.Add(param5);

            bool award_success = dm_awards.getProcedureData(awardsQueryString);
            if (award_success)
            {
                if (dm_awards.daResult.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow dr in dm_awards.daResult.Tables[0].Rows)
                    {
                        GrantModel gm = new GrantModel();
                        gm.GRANT_CODE = dr["GRANT_CODE"].ToString();
                        gm.FUND = dr["FUND"].ToString();
                        gm.GRANT_TITLE = dr["GRANT_TITLE"].ToString();
                        string pistr = dr["PI"].ToString();
                        if (pistr.IndexOf("NAME NOT FOUND") >= 0)
                        {
                            gm.PI = "N/A";
                        }
                        else
                        {
                            gm.PI = dr["PI"].ToString();
                        }
                        //gm.PI = dr["PI"].ToString();
                        gm.budget = System.Convert.ToDecimal(dr["budget"].ToString());
                        gm.expense = System.Convert.ToDecimal(dr["expense"].ToString());
                        gm.available = System.Convert.ToDecimal(dr["available"].ToString());
                        gm.encumbrances = System.Convert.ToDecimal(dr["encumbrances"].ToString());
                        gm.startDate = System.Convert.ToDateTime(dr["PROJECT_START_DATE"].ToString());
                        gm.endDate = System.Convert.ToDateTime(dr["PROJECT_END_DATE"].ToString());
                        //gm.CAF_NUM = dr["CAF_NUM"].ToString();
                        gm.AvailBalPect = System.Convert.ToDecimal(dr["AvailBalPect"].ToString());
                        gm.MthsRem = System.Convert.ToDecimal(dr["MthsRem"].ToString());
                        gm.AvailTimePect = System.Convert.ToDecimal(dr["AvailTimePect"].ToString());
                        Awards.Add(gm);
                    }
                }
            }
            return Awards;
        }

        public List<GrantEndsModel> BindAwardEnds(string orgcode, string view)
        {
            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }

            string awardEndsQueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_awd_ends";
            List<GrantEndsModel> AwardEnds = new List<GrantEndsModel>();

            DatabaseModel dm_ends = new DatabaseModel();
            ProcParam end_param1 = new ProcParam("v_pidm", user.pidm, "CHAR", "IN");
            ProcParam end_param2 = new ProcParam("v_view", view, "CHAR", "IN");  // testing for PI
            ProcParam end_param3 = new ProcParam("v_org", orgcode, "CHAR", "IN");  // testing for PI
            ProcParam end_param4 = new ProcParam("p_award_ends", null, "CURSOR", "OUT");
            dm_ends.procParams.Add(end_param1);
            dm_ends.procParams.Add(end_param2);
            dm_ends.procParams.Add(end_param3);
            dm_ends.procParams.Add(end_param4);

            bool ends_success = dm_ends.getProcedureData(awardEndsQueryString);
            if (ends_success)
            {
                if (dm_ends.daResult.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow dr in dm_ends.daResult.Tables[0].Rows)
                    {
                        GrantEndsModel gem = new GrantEndsModel();
                        gem.GRANT_CODE = dr["GRANT_CODE"].ToString();
                        gem.GRANT_TITLE = dr["TITLE"].ToString();
                        gem.endDate = System.Convert.ToDateTime(dr["END_DATE"].ToString());
                        AwardEnds.Add(gem);
                    }
                }
            }
            return AwardEnds;
        }

        public void BindNotes()
        {
            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }

            try
            {
                /*DatabaseModel dm = new DatabaseModel();
                bool selectstatus = false;

                selectstatus = dm.getSelectData(this.NotePolicyQuery);

                if (selectstatus)
                {
                    if (this.NotesPolicies != null)
                        NotesPolicies.Clear();

                    foreach (DataRow dr in dm.daResult.Tables[0].Rows)
                    {
                        string msg = dr["MESSAGE"].ToString();
                        NotesPolicies.Add(msg);
                    }
                }
                else
                {
                    throw new Exception("SQL Script running error");
                }
                dm.Close();*/ //comment out temparary
            }
            catch (Exception e)
            {
                throw new Exception("Error for getting notes and Policies. Error message is " + e.Message);
            }
        }
    }
}