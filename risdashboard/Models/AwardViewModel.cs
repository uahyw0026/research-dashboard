using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;

namespace risdashboard.Models
{
    public class AwardViewModel
    {     
        public UserModel user { get; set; }

        //[RequiredArray(ErrorMessage = "At least one email is required")]
        //[Display(Name = "Email")]
        //[DataType(DataType.EmailAddress)]
        public List<GrantModel> Awards { get; set; }
        public List<GrantEndsModel> AwardEnds { get; set; }
        public List<ProposalModel> Proposals { get; set; }

        public AwardViewModel()
        {
            Awards = new List<GrantModel>();         
            AwardEnds = new List<GrantEndsModel>();
            Proposals = new List<ProposalModel>();
        }
        public AwardViewModel(UserModel v_user)
        {
            Awards = new List<GrantModel>();
            AwardEnds = new List<GrantEndsModel>();
            Proposals = new List<ProposalModel>();
            user = v_user;
        }

        private string proposalqueryscript =
            @"SELECT proposal.PROPOSALID,
                   proposal.PROPOSALNUM,
                   PROPOSALTITLE,
                   LEADUNIT,
                   LEADUNITPARENT,
                   SPONSORNAME,
                   PROPOSALCOST,
                   PROPOSALSUBMITDATE,
                   PROPOSALSTARTDATE,
                   PROPOSALENDDATE
              FROM proposal
                   JOIN proposalpi
                       ON     proposal.PROPOSALID = proposalpi.PROPOSALID
                          AND proposal.PROPOSALnum = proposalpi.PROPOSALnum
             WHERE proposalpi.anum = :anumber AND proposalpi.CURRENTIND = 'y'";

        public List<GrantModel> BindAwards(string orgcode, string view)
        {
            string PIDataSource;
            string SchoolDataSource;
            string datasource;

            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }

            if (view == "1" ) // PI View
            {
                PIDataSource = ConfigurationManager.AppSettings["PI Data Retrieve Method"].ToString();
                datasource = (PIDataSource == "MaterializedView") ? "2" : "1";
            }
            else if (view == "2") // school view 
            {
                SchoolDataSource = ConfigurationManager.AppSettings["School Data Retrieve Method"].ToString();
                datasource = (SchoolDataSource == "MaterializedView") ? "2" : "1";
            }
            else
            {
                throw new Exception("View Parameter Error!");
            }

            string awardsQueryString = "RISDASH.uah_k_cogr_research_dashboard.uah_p_cogr_rdb_awards";
            List<GrantModel> Awards = new List<GrantModel>();

            DatabaseModel dm_awards = new DatabaseModel();
            ProcParam param1 = new ProcParam("v_pidm", user.pidm, "CHAR", "IN");
            ProcParam param2 = new ProcParam("v_view", view, "CHAR", "IN");  // testing for PI
            ProcParam param3 = new ProcParam("v_org", orgcode, "CHAR", "IN");  // testing for PI
            ProcParam param4 = new ProcParam("v_source", datasource, "CHAR", "IN");  // testing for PI
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
                        gm.ORGN = dr["ORGN"].ToString();
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
                        gem.FUND_CODE = dr["FUND_CODE"].ToString();
                        gem.ORGN = dr["ORGN"].ToString();
                        string pistr = dr["PI"].ToString();
                        if (pistr.IndexOf("NAME NOT FOUND") >= 0)
                        {
                            gem.PI = "N/A";
                        }
                        else
                        {
                            gem.PI = dr["PI"].ToString();
                        }
                        gem.startDate = System.Convert.ToDateTime(dr["START_DATE"].ToString());
                        gem.endDate = System.Convert.ToDateTime(dr["END_DATE"].ToString());
                        AwardEnds.Add(gem);
                    }
                }
            }
            return AwardEnds;
        }

        public bool BindProposals(string anumber = "")
        {
            bool querystatus = false;
            try
            {
                if (user == null)
                {
                    throw new Exception("User Identity is missing!");
                }

                string t_anum  = anumber == "" ? this.user.MyBamaID : anumber;
                OracleParameter[] parameters = new OracleParameter[] {
                        new OracleParameter("anumber",OracleDbType.Varchar2,t_anum, ParameterDirection.Input)};

                DatabaseModel dm = new DatabaseModel();
                querystatus = dm.getSelectData(this.proposalqueryscript, parameters);

                if (querystatus)
                {
                    if (dm.daResult.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow dr in dm.daResult.Tables[0].Rows)
                        {
                            DateTime submitdate;
                            DateTime startdate;
                            DateTime enddate;
                            bool validated;

                            ProposalModel prop = new ProposalModel();
                            prop.PROPOSALID = dr["PROPOSALID"].ToString();
                            prop.PROPOSALNUM = dr["PROPOSALNUM"].ToString();
                            prop.PROPOSALTITLE = dr["PROPOSALTITLE"].ToString();
                            prop.LEADUNIT = dr["LEADUNIT"].ToString();
                            prop.LEADUNITPARENT = dr["LEADUNITPARENT"].ToString();
                            prop.SPONSORNAME = dr["SPONSORNAME"].ToString();
                            prop.PROPOSALCOST = System.Convert.ToDecimal(dr["PROPOSALCOST"].ToString());

                            validated = DateTime.TryParse(dr["PROPOSALSUBMITDATE"].ToString(), out submitdate) ? true : false;
                            if (validated) prop.PROPOSALSUBMITDATE = submitdate.Date;

                            validated = DateTime.TryParse(dr["PROPOSALSTARTDATE"].ToString(), out startdate) ? true : false;
                            if (validated) prop.PROPOSALSTARTDATE = startdate.Date;

                            validated = DateTime.TryParse(dr["PROPOSALENDDATE"].ToString(), out enddate) ? true : false;
                            if (validated) prop.PROPOSALENDDATE = enddate.Date;
                           
                            this.Proposals.Add(prop);
                        }
                    }

                    foreach (OracleParameter pa in parameters)
                    {
                        pa.Dispose();
                    }

                    return true;
                }
                else
                {
                    throw new Exception("Bind Proposal failed");
                }
            }
            catch (Exception e)
            {
                throw new Exception("Bind Proposal failed, error message is " + e.Message);
            }
        }
    }

    public class GrantModel
    {
        public String GRANT_CODE { get; set; }
        public String GRANT_TITLE { get; set; }
        public String PI { get; set; }
        public String FUND { get; set; }
        public String ORGN { get; set; }
        public DateTime startDate { get; set; }
        public DateTime endDate { get; set; }
        public String CAF_NUM { get; set; }
        public decimal budget { get; set; }
        public decimal expense { get; set; }
        public decimal encumbrances { get; set; }
        public decimal available { get; set; }
        public decimal AvailBalPect { get; set; }
        public decimal MthsRem { get; set; }
        public decimal AvailTimePect { get; set; }

    }

    public class GrantEndsModel
    {
        public String GRANT_CODE { get; set; }
        public String GRANT_TITLE { get; set; }
        public String FUND_CODE { get; set; }
        public String ORGN { get; set; }
        public String PI { get; set; }
        public DateTime startDate { get; set; }
        public DateTime endDate { get; set; }

    }

    public class ProposalModel
    {
        public String PROPOSALID { get; set; }
        public String PROPOSALNUM { get; set; }
        public String PROPOSALTITLE { get; set; }
        public String LEADUNIT { get; set; }
        public String LEADUNITPARENT { get; set; }
        public String SPONSORNAME { get; set; }
        public decimal PROPOSALCOST { get; set; }
        public DateTime PROPOSALSUBMITDATE { get; set; }
        public DateTime PROPOSALSTARTDATE { get; set; }
        public DateTime PROPOSALENDDATE { get; set; }
    }
}