using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Linq.Expressions;

namespace risdashboard.Models
{
    public class FundViewModel
    {      
        public List<FundModel> Funds { get; set; }
        public string detail { get; set; }

        public UserModel user { get; set; }

        public FundViewModel()
        {
          Funds = new List<FundModel>();
          detail = "all";
        }

        public FundViewModel(UserModel v_user)
        {
            Funds = new List<FundModel>();
            detail = "all";
            user = v_user;
        }
        public bool BindFunds(string v_fund,string v_detail)
        {
            string QueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_awd_details";
            detail = v_detail;
            bool bindresult = false;

            try
            {
                // retrieve project info from Banner
                DatabaseModel dm_funds = new DatabaseModel();
                ProcParam param1 = new ProcParam("v_pidm", user.pidm, "CHAR", "IN");
                ProcParam param2 = new ProcParam("v_fundid", v_fund, "CHAR", "IN");
                ProcParam param3 = new ProcParam("v_source", "1", "CHAR", "IN");
                ProcParam param4 = new ProcParam("p_award_details", null, "CURSOR", "OUT");
                dm_funds.procParams.Add(param1);
                dm_funds.procParams.Add(param2);
                dm_funds.procParams.Add(param3);
                dm_funds.procParams.Add(param4);
                bool fund_success = dm_funds.getProcedureData(QueryString);
                if (fund_success)
                {
                    if (dm_funds.daResult.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow dr in dm_funds.daResult.Tables[0].Rows)
                        {
                            FundModel fm = new FundModel();
                            fm.GRANT_CODE = dr["GRANT_CODE"].ToString();
                            fm.GRANT_TITLE = dr["GRANT_TITLE"].ToString();
                            fm.FUND = dr["FUND"].ToString();
                            fm.ORGN = dr["ORGN"].ToString();
                            fm.COA = dr["COA"].ToString();
                            fm.ACCT_TITLE = dr["ACCT_TITLE"].ToString();
                            fm.ACCOUNT = dr["ACCOUNT"].ToString();
                            fm.budget = System.Convert.ToDecimal(dr["budget"].ToString());
                            fm.expense = System.Convert.ToDecimal(dr["expense"].ToString());
                            fm.available = System.Convert.ToDecimal(dr["available"].ToString());
                            fm.encumbrances = System.Convert.ToDecimal(dr["encumbrances"].ToString());
                            Funds.Add(fm);
                        }
                        bindresult = true;
                    }
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error when quering information for fund " + v_fund);
            }
            return bindresult;
        }
    }

    public class FundModel
    {
        public String GRANT_CODE { get; set; }
        public String GRANT_TITLE { get; set; }
        public String COA { get; set; }
        public String FUND { get; set; }
        public String ORGN { get; set; }
        public String ACCT_TITLE { get; set; }
        public String ACCOUNT { get; set; }
        public decimal budget { get; set; }
        public decimal expense { get; set; }
        public decimal encumbrances { get; set; }
        public decimal available { get; set; }
    }
}