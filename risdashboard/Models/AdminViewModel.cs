using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using System.Reflection;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using risdashboard.Models;

namespace risdashboard.Models
{
    public class AdminViewModel
    {
        private string insertSchoolUserScript =
            @"INSERT INTO rdborgnmap (
                rdborgnmap_pidm,
                rdborgnmap_orgn_code,
                rdborgnmap_eff_date,
                rdborgnmap_nchg_date,
                rdborgnmap_creator
            ) VALUES (
                :pidm,
                :orgn,
                to_date(to_char(sysdate, 'MM/DD/YYYY'), 'mm/dd/yyyy'),
                TO_DATE('12/31/2099', 'mm/dd/yyyy'),
                :creator
            )";
        private string ExpireUserScript =
            @"UPDATE risdash.rdborgnmap
                SET rdborgnmap_nchg_date = to_date(to_char(sysdate, 'MM/DD/YYYY'), 'mm/dd/yyyy')
            WHERE
                    rdborgnmap_pidm = :pidm
                AND rdborgnmap_orgn_code = :orgn
                AND rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy')";

        private string getSchoolUsers =
            @"SELECT
                pidm,
                cwid,
                schooluser,
                orgn,
                orgn_name,
                orgn_desc,
                updatedate,
                nvl2(saturn.spriden.spriden_last_name, saturn.spriden.spriden_last_name
                                                        || ', '
                                                        || substr(saturn.spriden.spriden_first_name, 1, 1), 'NA') AS creator
            FROM
                (
                    SELECT
                        rdborgnmap.rdborgnmap_pidm         AS pidm,
                        saturn.spriden.spriden_id          AS cwid,
                        nvl2(saturn.spriden.spriden_last_name, saturn.spriden.spriden_last_name
                                                                || ', '
                                                                || substr(saturn.spriden.spriden_first_name, 1, 1), 'NA') AS schooluser,
                        rdborgnmap.rdborgnmap_orgn_code    AS orgn,
                        (
                            CASE rdborgnmap.rdborgnmap_orgn_code
                                WHEN 'RDBADM' THEN
                                    'Administrator for Research Dashboard website'
                                ELSE
                                    temporgn.orgnname
                            END
                        ) AS orgn_name,
                        rdborgnmap.rdborgnmap_orgn_code
                        || ' - '
                        || (
                            CASE rdborgnmap.rdborgnmap_orgn_code
                                WHEN 'RDBADM' THEN
                                    'Administrator for Research Dashboard website'
                                ELSE
                                    temporgn.orgnname
                            END
                        ) AS orgn_desc,
                        rdborgnmap.rdborgnmap_eff_date     AS updatedate,
                        rdborgnmap_creator                 AS creator
                    FROM
                        risdash.rdborgnmap
                        LEFT OUTER JOIN (
                            SELECT
                                orgprefix,
                                LISTAGG(unitname, ' | ') WITHIN GROUP(
                                    ORDER BY
                                        unitnumber
                                ) AS orgnname
                            FROM
                                risdash.rdborgn
                            GROUP BY
                                orgprefix
                        ) temporgn ON rdborgnmap.rdborgnmap_orgn_code = temporgn.orgprefix
                        LEFT OUTER JOIN saturn.spriden ON rdborgnmap.rdborgnmap_pidm = saturn.spriden.spriden_pidm
                    WHERE
                        saturn.spriden.spriden_change_ind IS NULL
                        AND rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy')
                ) map
                LEFT OUTER JOIN saturn.spriden ON map.creator = saturn.spriden.spriden_id
                                                    AND saturn.spriden.spriden_change_ind IS NULL";

        private string getSchools =
            @"SELECT
                    'RDBADM'           AS orgn,
                    'RDBADM - Administrator for Research Dashboard'  AS orgn_desc
                FROM
                    dual
                UNION ALL
                SELECT
                    orgn,
                    orgn_desc
                FROM
                    (
                        SELECT DISTINCT
                            orgprefix             AS orgn,
                            orgnname              AS orgname,
                            orgprefix
                            || ' - '
                            || orgnname AS orgn_desc,
                            length(orgprefix)     AS orgn_len
                        FROM
                            (
                                SELECT
                                    orgprefix,
                                    LISTAGG(unitname, ' | ') WITHIN GROUP(
                                        ORDER BY
                                            unitnumber
                                    ) AS orgnname
                                FROM
                                    risdash.rdborgn
                                GROUP BY
                                    orgprefix
                            ) temporgn
                        WHERE
                            NOT orgprefix IS NULL
                        ORDER BY
                            orgn_len,
                            orgn
                    )";

        private string getUserScript =
            @"SELECT
                    user_pidm,
                    user_name
                FROM
                    (
                        SELECT
                            saturn.spriden.spriden_pidm AS user_pidm,
                            nvl(saturn.spriden.spriden_first_name
                                || ' '
                                || nvl2(saturn.spriden.spriden_mi, saturn.spriden.spriden_mi
                                                                   || ' ', '')
                                || saturn.spriden.spriden_last_name, 'NA') AS user_name
                        FROM
                            saturn.spriden
                        WHERE
                                saturn.spriden.spriden_id = :ANumber
                            AND saturn.spriden.spriden_change_ind IS NULL
                        UNION ALL
                        SELECT
                            0                  AS user_pidm,
                            'No Record Found'  AS user_name
                        FROM
                            dual
                    )
                ORDER BY
                    user_pidm DESC";

        private string getMVStatusScript =
            @"SELECT
                    owner,
                    mview_name,
                    last_refresh_type,
                    last_refresh_date
                FROM
                    all_mviews
                WHERE
                    owner = 'RISDASH'";
        public UserModel user { get; set; }

        public SelectList Orgns { get; set; }

        public List<DeanModel> Deans { get; set; }

        public NewDeanModel NewDean { get; set; }

        public List<MVStatusModel> MVStatuses { get; set; }

        public AdminViewModel()
        {
            Deans = new List<DeanModel>();
        }
        public AdminViewModel(UserModel v_user)
        {
            Deans = new List<DeanModel>();
            user = v_user;
        }
        public List<DeanModel> BindSchoolUsers()
        {
            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }
            List<DeanModel> Deans = new List<DeanModel>();

            DatabaseModel dm_awards = new DatabaseModel();
            bool school_success = dm_awards.getSelectData(getSchoolUsers);
            if (school_success)
            {
                if (dm_awards.daResult.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow dr in dm_awards.daResult.Tables[0].Rows)
                    {
                        DeanModel dm = new DeanModel();
                        dm.PIDM = dr["PIDM"].ToString();
                        dm.CWID = dr["CWID"].ToString();
                        dm.UserName = dr["SCHOOLUSER"].ToString();
                        dm.Orgn = dr["ORGN"].ToString();
                        dm.OrgnName = dr["ORGN_NAME"].ToString();
                        dm.OrgnDesc = dr["ORGN_DESC"].ToString();
                        dm.Creator = dr["CREATOR"].ToString();
                        dm.UpdateDate = System.Convert.ToDateTime(dr["UPDATEDATE"].ToString());
                        Deans.Add(dm);
                    }
                }
            }
            return Deans;
        }

        public void BindOrgns()
        {
            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }

            DatabaseModel dm_orgns = new DatabaseModel();
            bool school_success = dm_orgns.getSelectData(getSchools);
            if (school_success)
            {
                if (dm_orgns.daResult.Tables[0].Rows.Count > 0)
                {
                    this.Orgns = DatabaseModel.DT2SelectList(dm_orgns.daResult.Tables[0], "orgn", "orgn_desc");
                }
            }
        }

        public bool BindNewDeanUser(string anumber)
        {
            bool querystatus = false;
            try
            {
                this.NewDean = new NewDeanModel();

                OracleParameter[] parameters = new OracleParameter[] {
                        new OracleParameter("anumber",OracleDbType.Varchar2,anumber, ParameterDirection.Input)};
                DatabaseModel dm = new DatabaseModel();
                querystatus = dm.getSelectData(this.getUserScript, parameters);

                if (querystatus)
                {
                    if (dm.daResult.Tables[0].Rows.Count > 1)
                    {
                        DataRow dr= dm.daResult.Tables[0].Rows[0];                     
                                                 
                        this.NewDean.Pidm = dr["user_pidm"].ToString();
                        this.NewDean.UserName = dr["user_name"].ToString();
                        this.NewDean.CWID = anumber;                       
                    }
                    
                    foreach (OracleParameter pa in parameters)
                    {
                        pa.Dispose();
                    }
                    
                    return true;
                }
                else
                {
                    throw new Exception("Bind Dean User failed");
                }
            }
            catch (Exception e)
            {
                throw new Exception("Bind Dean User failed, error message is " + e.Message);
            }
        }
        public bool InsertNewDeanUser()
        {
            //insert new certifications 
            bool execstatus = false;
            if (this.NewDean == null) return false;

            try
            {
                OracleParameter[] parameters = new OracleParameter[] {
                        new OracleParameter("pidm",OracleDbType.Int16, this.NewDean.Pidm, ParameterDirection.Input),
                        new OracleParameter("orgn",OracleDbType.Varchar2, this.NewDean.Orgn, ParameterDirection.Input),
                        new OracleParameter("creator",OracleDbType.Varchar2, this.user.MyBamaID, ParameterDirection.Input)};
                DatabaseModel dm = new DatabaseModel();
                execstatus = dm.RunOracleCommandWithParams(this.insertSchoolUserScript, parameters);

                if (execstatus)
                {
                    foreach (OracleParameter pa in parameters)
                    {
                        pa.Dispose();
                    }
                    return true;
                }
                else
                {
                    throw new Exception("Insert Dean User failed");
                }
            }
            catch (Exception e)
            {
                throw new Exception("Insert Certiifcation failed, error message is " + e.Message);
            }
        }
        public bool DeleteDeanUser(string pidm, string orgn)
        {
            //insert new certifications 
            bool execstatus = false;
            try
            {
                OracleParameter[] parameters = new OracleParameter[] {
                        new OracleParameter("pidm",OracleDbType.Int16, pidm, ParameterDirection.Input),
                        new OracleParameter("orgn",OracleDbType.Varchar2, orgn, ParameterDirection.Input)};
                DatabaseModel dm = new DatabaseModel();
                execstatus = dm.RunOracleCommandWithParams(this.ExpireUserScript, parameters); //expires dean user instead of delete for audit purpose

                if (execstatus)
                {
                    foreach (OracleParameter pa in parameters)
                    {
                        pa.Dispose();
                    }
                    return true;
                }
                else
                {
                    throw new Exception("Delete Dean User failed");
                }
            }
            catch (Exception e)
            {
                throw new Exception("Delete Dean User failed, error message is " + e.Message);
            }
        }
        public bool BindMVStatus()
        {
            if (user == null)
            {
                throw new Exception("User Identity is missing!");
            }

            DatabaseModel dm_mv = new DatabaseModel();
            bool MV_success = dm_mv.getSelectData(getMVStatusScript);
            if (MV_success)
            {
                if (dm_mv.daResult.Tables[0].Rows.Count > 0)
                {
                    this.MVStatuses = new List<MVStatusModel>();
                    foreach (DataRow dr in dm_mv.daResult.Tables[0].Rows)
                    {
                        MVStatusModel MVStatus = new MVStatusModel();
                        MVStatus.owner = dr["owner"].ToString();
                        MVStatus.mview_name = dr["mview_name"].ToString();
                        MVStatus.last_refresh_type = dr["last_refresh_type"].ToString();
                        MVStatus.last_refresh_date = System.Convert.ToDateTime(dr["last_refresh_date"].ToString());
                        this.MVStatuses.Add(MVStatus);
                    }

                    return true;
                }
                else
                    return false;                
            }
            else 
                return false;
        }
    }
    public class DeanModel
    {
        public String PIDM { get; set; }
        public String CWID { get; set; }
        public String UserName { get; set; }
        public String Orgn { get; set; }
        public String OrgnName { get; set; }
        public String OrgnDesc { get; set; }
        public String Creator { get; set; }
        public DateTime UpdateDate { get; set; }
    }

    public class NewDeanModel
    {
        // property for creating dean user
        [RegularExpression(@"A[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]", ErrorMessage = "Please enter proper A Number.")]
        [StringLength(9)]
        [DisplayName("A-Number")]
        [Required]
        public string CWID { get; set; }

        [DisplayName("Orgn Code")]
        public string Orgn { get; set; }
        
        [RegularExpression(@"^[1-9]\d*$", ErrorMessage = "user pidm is required. Please enter correct A-Number.")]
        [DisplayName("User PIDM")]
        [Required]
        public string Pidm { get; set; }

        [DisplayName("User Name")]
        [Required(ErrorMessage = "user name is needed. Please enter correct A-Number")]
        public String UserName { get; set; }   
    }

    public class MVStatusModel
    {
        public String owner { get; set; }
        public String mview_name { get; set; }
        public String last_refresh_type { get; set; }       
        public DateTime last_refresh_date { get; set; }
    }
}
    