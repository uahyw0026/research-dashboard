using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using risdashboard.Models;

namespace risdashboard.Models
{
    public class AccountViewModel
    {
        public List<AccountModel> Accounts { get; set; }
        
        public string transaction_type { get; set; }
        public UserModel user { get; set; }

        public AccountViewModel()
        {
            Accounts = new List<AccountModel>();
        }
        public bool BindAccount(string v_fund, string v_account, string v_transType)
        {
            string AccountQueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_acct_trans";
            string PayrollQueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_acct_payroll";
            bool bindresult = false;

            try
            {
                // retrieve account info from Banner
                DatabaseModel dm_accounts = new DatabaseModel();
                ProcParam param1 = new ProcParam("v_pidm", user.pidm, "CHAR", "IN");
                ProcParam param2 = new ProcParam("v_fundid", v_fund, "CHAR", "IN");
                ProcParam param3 = new ProcParam("v_acctid", v_account, "CHAR", "IN");
                ProcParam param4 = new ProcParam("v_trans_type", v_transType, "CHAR", "IN");
                ProcParam param5 = new ProcParam("v_source", "1", "CHAR", "IN");
                ProcParam param6 = new ProcParam("p_account_transactions", null, "CURSOR", "OUT");
                dm_accounts.procParams.Add(param1);
                dm_accounts.procParams.Add(param2);
                dm_accounts.procParams.Add(param3);
                dm_accounts.procParams.Add(param4);
                dm_accounts.procParams.Add(param5);
                dm_accounts.procParams.Add(param6);

                bool award_success = dm_accounts.getProcedureData(AccountQueryString);
                if (award_success)
                {
                    if (dm_accounts.daResult.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow dr in dm_accounts.daResult.Tables[0].Rows)
                        {
                            AccountModel am = new AccountModel();
                            am.GRANT_CODE = dr["GRANT_CODE"].ToString();
                            am.GRANT_TITLE = dr["GRANT_TITLE"].ToString();
                            am.FUND = dr["FUND"].ToString();
                            am.COA = dr["COA"].ToString();
                            am.ACCT_TITLE = dr["ACCT_TITLE"].ToString();
                            am.ACCOUNT = dr["ACCOUNT"].ToString();
                            am.ORG_CODE = dr["ORG_CODE"].ToString();
                            am.TRANS_DATE = System.Convert.ToDateTime(dr["TRANS_DATE"].ToString());
                            am.TRANS_DESC = dr["TRANS_DESC"].ToString();
                            am.DOC_TYPE = dr["DOC_TYPE"].ToString();
                            am.PROGRAM = dr["PROGRAM"].ToString();
                            am.FIELD_CODE = dr["FIELD_CODE"].ToString();
                            am.DOCUMENT = dr["DOCUMENT"].ToString();
                            am.SEQ_GROUP = dr["SEQ_GROUP"].ToString();
                            am.ORG_CODE = dr["ORG_CODE"].ToString();
                            am.AMOUNT = System.Convert.ToDecimal(dr["AMOUNT"].ToString());
                            am.DOC_LINK = dr["DOC_LINK"].ToString();
                            am.FCodeDesc = dr["FCodeDesc"].ToString();
                            Accounts.Add(am);
                        }
                    }
                }

                // retrieve payroll info from Banner
                DatabaseModel dm_payrolls = new DatabaseModel();
                ProcParam pl_param1 = new ProcParam("v_fundid", v_fund, "CHAR", "IN");
                ProcParam pl_param2 = new ProcParam("v_acctid", v_account, "CHAR", "IN");
                ProcParam pl_param3 = new ProcParam("v_doc", "", "CHAR", "IN");
                ProcParam pl_param4 = new ProcParam("v_trans_type", v_transType, "CHAR", "IN");
                ProcParam pl_param5 = new ProcParam("v_source", "1", "CHAR", "IN");
                ProcParam pl_param6 = new ProcParam("p_account_payroll", null, "CURSOR", "OUT");
                dm_payrolls.procParams.Add(pl_param1);
                dm_payrolls.procParams.Add(pl_param2);
                dm_payrolls.procParams.Add(pl_param3);
                dm_payrolls.procParams.Add(pl_param4);
                dm_payrolls.procParams.Add(pl_param5);
                dm_payrolls.procParams.Add(pl_param6);

                bool payroll_success = dm_payrolls.getProcedureData(PayrollQueryString);
                if (payroll_success)
                {
                    if (dm_payrolls.daResult.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow dr in dm_payrolls.daResult.Tables[0].Rows)
                        {
                            PayrollModel pl = new PayrollModel();
                            pl.DOCUMENT = dr["DOCUMENT"].ToString();
                            pl.seq_group = dr.IsNull("seq_group") ? "" : dr["seq_group"].ToString();
                            pl.username = dr["username"].ToString();
                            pl.amount = System.Convert.ToDecimal(dr.IsNull("amount") ? "0.00" : dr["amount"].ToString());

                            foreach (AccountModel am in Accounts)
                            {
                                if (am.DOCUMENT == pl.DOCUMENT && am.SEQ_GROUP == pl.seq_group)
                                {
                                    am.Payrolls.Add(pl);
                                }
                            }
                        }
                    }
                }

                if (v_transType == "BUDGET")
                {
                    transaction_type = "Budget";
                }
                else if (v_transType == "EXPENSE")
                {
                    transaction_type = "Expense";
                }
                else if (v_transType == "ENCUMBRANCES")
                {
                    transaction_type = "Encumbrances";
                }
                bindresult = true;
            }
            catch (Exception e)
            {
                throw new Exception("Error when quering information for Account " + v_account + " fund " + v_fund);
            }
            return bindresult;
        }
    }
    public class AccountModel
    {
        public String GRANT_CODE { get; set; }
        public String GRANT_TITLE { get; set; }
        public String COA { get; set; }
        public String FUND { get; set; }
        public String ACCT_TITLE { get; set; }
        public String ACCOUNT { get; set; }
        public String ORG_CODE { get; set; }
        public DateTime TRANS_DATE { get; set; }
        public String TRANS_DESC { get; set; }
        public String DOC_TYPE { get; set; }
        public String PROGRAM { get; set; }
        public String FIELD_CODE { get; set; }
        public String DOCUMENT { get; set; }
        public String SEQ_GROUP { get; set; }
        public decimal AMOUNT { get; set; }
        public String DOC_LINK { get; set; }
        public String FCodeDesc { get; set; }
        public List<PayrollModel> Payrolls { get; set; }

        public AccountModel()
        {
            Payrolls = new List<PayrollModel>();
        }
    }
    public class PayrollModel
    {
        public String DOCUMENT { get; set; }
        public String seq_group { get; set; }
        public String username { get; set; }
        public decimal amount { get; set; }
    }
}