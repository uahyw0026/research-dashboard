using System;
using System.Collections.Generic;
using System.Text;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System.Data;

namespace risdashupload
{
    public class ProposalRecords
    {
        private string TruncateTempProposalTable =
           @"truncate table RISDASH.TempProposal";

        private string ResetTempProposalTableSequence ="RISDASH.UAH_K_RESEARCHDB_IMPORT.Reset_Sequence"; 

        private string ResetTempAwardTableSequence =
           @"EXEC RISDASH.UAH_K_RESEARCHDB_IMPORT.Reset_Sequence ('TEMPAWARD_IMPORTLINENUMBER_SEQ')";

        public List<Proposal> Proposals { get; set; }
        public string error_message { get; set; }
        public ProposalRecords()
        {
            Proposals = new List<Proposal>();
        }

        public bool populateProposalRecords(string proposalfile, string user)
        {
            Validator valid = new Validator();
            int linenumber = 0;
            bool allValidated = true;
            string filename = "";

            try
            {

                using (CsvFileReader reader = new CsvFileReader(proposalfile))
                {
                    CsvRow row = new CsvRow();
                    DateTime submitdate;
                    DateTime startdate;
                    DateTime enddate;

                    while (reader.ReadRow(row))
                    {
                        if (row.Count == 20)
                        {
                            Proposal proposalRec = new Proposal();
                            int i;
                            for (i = 0; i < row.Count; i++)
                            {
                                string s = row[i];
                                bool validated = true;
                                switch (i)
                                {
                                    case 0:
                                        validated = valid.IsAllNumbers(s) ? true : false;
                                        proposalRec.PROPOSALID = validated ? s : null;
                                        break;
                                    case 1:
                                        validated = valid.IsAllNumbers(s) ? true : false;
                                        proposalRec.PROPOSALNUM= validated ? s : null;
                                        break;
                                    case 2:
                                        validated = valid.IsMaxLength(500, s) ? true : false;
                                        proposalRec.PROPOSALTITLE = validated ? s : null;
                                        break;
                                    case 3:
                                        validated = valid.IsA_Number(s) ? true : false;
                                        proposalRec.ANUM = validated ? s : null;
                                        break;
                                    case 4:
                                        validated = (valid.IsMaxLength(60, s)) ? true : false;
                                        proposalRec.LASTNAME = validated ? s : null;
                                        break;
                                    case 5:
                                        validated = (valid.IsMaxLength(60, s)) ? true : false;
                                        proposalRec.FIRSTNAME = validated ? s : null;
                                        break;
                                    case 6:
                                        validated = (valid.IsMaxLength(60, s)) ? true : false;
                                        proposalRec.MIDDLENAME = validated ? s : null;
                                        break;
                                    case 7:
                                        validated = (s.ToString().Length==6) ? true : false;
                                        proposalRec.HOMEUNIT = validated ? s : null;
                                        break;
                                    case 8:
                                        validated = (valid.IsMaxLength(255, s)) ? true : false;
                                        proposalRec.HOMEUNITNAME = validated ? s : null;
                                        break;
                                    case 9:
                                        validated = (s.ToString().Length == 6) ? true : false;
                                        proposalRec.HOMEUNITPARENT = validated ? s : null;
                                        break;
                                    case 10:
                                        validated = (valid.IsMaxLength(255, s)) ? true : false;
                                        proposalRec.HOMEUNITPARENTNAME = validated ? s : null;
                                        break;
                                    case 11:
                                        validated = (s.ToString().Length == 6) ? true : false;
                                        proposalRec.LEADUNIT = validated ? s : null;
                                        break;
                                    case 12:
                                        validated = (valid.IsMaxLength(255, s)) ? true : false;
                                        proposalRec.LEADUNITNAME = validated ? s : null;
                                        break;
                                    case 13:
                                        validated = (s.ToString().Length == 6) ? true : false;
                                        proposalRec.LEADUNITPARENT = validated ? s : null;
                                        break;
                                    case 14:
                                        validated = (valid.IsMaxLength(255, s)) ? true : false;
                                        proposalRec.LEADUNITPARENTNAME = validated ? s : null;
                                        break;
                                    case 15:
                                        validated = (valid.IsMaxLength(500, s)) ? true : false;
                                        proposalRec.SPONSORNAME = validated ? s : null;
                                        break;
                                    case 16:
                                        if (s.Trim() == "")
                                        {
                                            validated = true;
                                            proposalRec.PROPOSALSUBMITDATE = ""; 
                                        }
                                        else
                                        {
                                            validated = DateTime.TryParse(s, out submitdate)  ? true : false;
                                            proposalRec.PROPOSALSUBMITDATE = validated ? submitdate.ToShortDateString() : "";
                                        }                                        
                                        break;
                                    case 17:
                                        if (s.Trim() == "")
                                        {
                                            validated = true;
                                            proposalRec.PROPOSALSTARTDATE = "";
                                        }
                                        else
                                        {
                                            validated = DateTime.TryParse(s, out startdate) ? true : false;
                                            proposalRec.PROPOSALSTARTDATE = validated ? startdate.ToShortDateString() : "";
                                        }
                                        break; 
                                    case 18:
                                        if (s.Trim() == "")
                                        {
                                            validated = true;
                                            proposalRec.PROPOSALENDDATE = "";
                                        }
                                        else
                                        {
                                            validated = DateTime.TryParse(s, out enddate) ? true : false;
                                            proposalRec.PROPOSALENDDATE = validated ? enddate.ToShortDateString() : "";
                                        }
                                        break; 
                                    case 19:
                                        validated = (valid.IsDecimalType(s)) ? true : false;
                                        proposalRec.PROPOSALCOST = validated ? s : "";
                                        break;
                                }
                                if (!validated)
                                {
                                    allValidated = false;
                                    this.error_message = "Proposal file validation failure at line# " + (linenumber + 1).ToString() + " and column# " + (i + 1).ToString();
                                    break;
                                }
                            }

                            if (allValidated)
                            {
                                this.Proposals.Add(proposalRec);
                            }
                            else
                            {
                                break;
                            }
                            linenumber = linenumber + 1;
                        }
                        else
                        {
                            allValidated = false;
                            this.error_message = "Security file validation failure at line# " + linenumber.ToString() + " for missing columns";
                            break;
                        }
                    }
                }

                if (allValidated)
                {
                    bool insertStatus = true;
                    ProcParam param1, param2, param3, param4;

                    //clear data in TEMPPROPOSAL table
                    Database dm = new Database();
                    dm.runOracleCommand(this.TruncateTempProposalTable);

                    //reset TEMPPROPOSAL_IMPORTLINENUMBER_SEQ for insertion
                    param1 = new ProcParam("p_seq_name", "TEMPPROPOSAL_IMPORTLINENUMBER_SEQ", "NVarChar", "IN");
                    param2 = new ProcParam("p_val", "0", "NUMBER", "IN");
                    param3 = new ProcParam("v_strOutput", null, "NVarChar", "OUT");
                    param4 = new ProcParam("v_strflag", null, "NUMBER", "OUT");
                    dm.procParams.Add(param1);
                    dm.procParams.Add(param2);
                    dm.procParams.Add(param3);
                    dm.procParams.Add(param4);


                    bool resetseq_success = dm.executeProcedureWithoutOutput(this.ResetTempProposalTableSequence);

                    if (!resetseq_success)
                    {
                        this.error_message = "Reset sequence value for temp Proposal table failed";
                        return false;
                    }
                    dm.procParams.Clear();

                    // insert proposal records to TEMPPROPOSAL table
                    foreach (Proposal proposalRM in this.Proposals)
                    {
                        insertStatus = proposalRM.insertProposalRecordToDB();
                        if (!insertStatus)
                        {
                            throw new Exception("insertion failed for proposal " + proposalRM.PROPOSALID);
                        }
                    }

                    // insert proposal records to TEMPPROPOSAL table
                    if (insertStatus)
                    {
                        string ImportProposalProc = "RISDASH.UAH_K_RESEARCHDB_IMPORT.ImportProposal";
                        string[] FileNameArray = proposalfile.Split('\\');
                        int cnt = FileNameArray.Length;
                        filename = cnt > 0 ? FileNameArray[cnt - 1] : proposalfile;

                        param1 = new ProcParam("v_filename", filename, "NVarChar", "IN");
                        param2 = new ProcParam("v_importUser", user, "NVarChar", "IN");
                        param3 = new ProcParam("v_strOutput", null, "NVarChar", "OUT");
                        param4 = new ProcParam("v_strflag", null, "NUMBER", "OUT");


                        dm.procParams.Add(param1);
                        dm.procParams.Add(param2);
                        dm.procParams.Add(param3);
                        dm.procParams.Add(param4);

                        bool cert_success = dm.executeProcedureWithoutOutput(ImportProposalProc);

                        if (cert_success)
                        {
                            this.error_message = "Import for proposal file " + filename + " is successful!";
                            return true;
                        }
                        else
                        {

                            this.error_message = "Import for proopsal file " + filename + " is failed! Please check record table below for details.";
                            return true;
                        }
                    }
                    else
                    {
                        this.error_message = "Proposal file import step is failed due to temp proposal table insertion error";
                        return false;
                    }
                }
            }
            catch (Exception e)
            {
                this.error_message = "Proposal file import failure. Error message is " + e.Message;
            }
            return false;
        }

    }

    public class Proposal
    {
        private string proposalRecordInsert =
        @"INSERT INTO RISDASH.TEMPPROPOSAL (PROPOSALID,
                                  PROPOSALNUM,
                                  PROPOSALTITLE,
                                  ANUM,
                                  LASTNAME,
                                  FIRSTNAME,
                                  MIDDLENAME,
                                  HOMEUNIT,
                                  HOMEUNITNAME,
                                  HOMEUNITPARENT,
                                  HOMEUNITPARENTNAME,
                                  LEADUNIT,
                                  LEADUNITNAME,
                                  LEADUNITPARENT,
                                  LEADUNITPARENTNAME,
                                  SPONSORNAME,
                                  PROPOSALCOST,
                                  PROPOSALSUBMITDATE,
                                  PROPOSALSTARTDATE,
                                  PROPOSALENDDATE)
             VALUES ( :PROPOSALID,
                     :PROPOSALNUM,
                     :PROPOSALTITLE,
                     :ANUM,
                     :LASTNAME,
                     :FIRSTNAME,
                     :MIDDLENAME,
                     :HOMEUNIT,
                     :HOMEUNITNAME,
                     :HOMEUNITPARENT,
                     :HOMEUNITPARENTNAME,
                     :LEADUNIT,
                     :LEADUNITNAME,
                     :LEADUNITPARENT,
                     :LEADUNITPARENTNAME,
                     :SPONSORNAME,
                     :PROPOSALCOST,
                     TO_DATE ( :PROPOSALSUBMITDATE, 'mm/dd/yyyy'),
                     TO_DATE ( :PROPOSALSTARTDATE, 'mm/dd/yyyy'),
                     TO_DATE ( :PROPOSALENDDATE, 'mm/dd/yyyy'))";

        public string PROPOSALID { get; set; }
        public string PROPOSALNUM { get; set; }
        public string PROPOSALTITLE { get; set; }
        public string ANUM { get; set; }
        public string LASTNAME { get; set; }
        public string FIRSTNAME { get; set; }
        public string MIDDLENAME { get; set; }
        public string HOMEUNIT { get; set; }
        public string HOMEUNITNAME { get; set; }
        public string HOMEUNITPARENT { get; set; }
        public string HOMEUNITPARENTNAME { get; set; }
        public string LEADUNIT { get; set; }
        public string LEADUNITNAME { get; set; }
        public string LEADUNITPARENT { get; set; }
        public string LEADUNITPARENTNAME { get; set; }
        public string SPONSORNAME { get; set; }
        public string PROPOSALCOST { get; set; }
        public string PROPOSALSUBMITDATE { get; set; }
        public string PROPOSALSTARTDATE { get; set; }
        public string PROPOSALENDDATE { get; set; }

        public bool insertProposalRecordToDB()
        {
            try
            {
                OracleParameter para_submitdate;
                OracleParameter para_startdate;
                OracleParameter para_enddate;

                if (this.PROPOSALSUBMITDATE.Trim() == "")
                {
                    para_submitdate = new OracleParameter("PROPOSALSUBMITDATE", OracleDbType.Varchar2, this.PROPOSALSUBMITDATE.Trim(), ParameterDirection.Input);
                }
                else
                {
                    DateTime submitdate = DateTime.Parse(this.PROPOSALSUBMITDATE);
                    para_submitdate = new OracleParameter("PROPOSALSUBMITDATE", OracleDbType.Varchar2, submitdate.Date.ToString("MM/dd/yyyy"), ParameterDirection.Input);
                }

                if (this.PROPOSALSTARTDATE.Trim() == "")
                {
                    para_startdate = new OracleParameter("PROPOSALSTARTDATE", OracleDbType.Varchar2, this.PROPOSALSTARTDATE.Trim(), ParameterDirection.Input);
                }
                else
                {
                    DateTime startdate = DateTime.Parse(this.PROPOSALSTARTDATE);
                    para_startdate = new OracleParameter("PROPOSALSTARTDATE", OracleDbType.Varchar2, startdate.Date.ToString("MM/dd/yyyy"), ParameterDirection.Input);
                }

                if (this.PROPOSALENDDATE.Trim() == "")
                {
                    para_enddate = new OracleParameter("PROPOSALENDDATE", OracleDbType.Varchar2, this.PROPOSALENDDATE.Trim(), ParameterDirection.Input);
                }
                else
                {
                    DateTime enddate = DateTime.Parse(this.PROPOSALENDDATE);
                    para_enddate = new OracleParameter("PROPOSALENDDATE", OracleDbType.Varchar2, enddate.Date.ToString("MM/dd/yyyy"), ParameterDirection.Input);
                }


                OracleParameter[] parameters = new OracleParameter[] {
                         new OracleParameter("PROPOSALID",OracleDbType.Int16,this.PROPOSALID, ParameterDirection.Input),
                         new OracleParameter("PROPOSALNUM",OracleDbType.Varchar2,this.PROPOSALNUM, ParameterDirection.Input),
                         new OracleParameter("PROPOSALTITLE",OracleDbType.Varchar2,this.PROPOSALTITLE, ParameterDirection.Input),
                         new OracleParameter("ANUM",OracleDbType.Varchar2,this.ANUM, ParameterDirection.Input),
                         new OracleParameter("LASTNAME",OracleDbType.Varchar2,this.LASTNAME, ParameterDirection.Input),
                         new OracleParameter("FIRSTNAME",OracleDbType.Varchar2,this.FIRSTNAME, ParameterDirection.Input),
                         new OracleParameter("MIDDLENAME",OracleDbType.Varchar2,this.MIDDLENAME, ParameterDirection.Input),
                         new OracleParameter("HOMEUNIT",OracleDbType.Varchar2,this.HOMEUNIT, ParameterDirection.Input),
                         new OracleParameter("HOMEUNITNAME",OracleDbType.Varchar2,this.HOMEUNITNAME, ParameterDirection.Input),
                         new OracleParameter("HOMEUNITPARENT",OracleDbType.Varchar2,this.HOMEUNITPARENT, ParameterDirection.Input),
                         new OracleParameter("HOMEUNITPARENTNAME",OracleDbType.Varchar2,this.HOMEUNITPARENTNAME, ParameterDirection.Input),
                         new OracleParameter("LEADUNIT",OracleDbType.Varchar2,this.LEADUNIT, ParameterDirection.Input),
                         new OracleParameter("LEADUNITNAME",OracleDbType.Varchar2,this.LEADUNITNAME, ParameterDirection.Input),
                         new OracleParameter("LEADUNITPARENT",OracleDbType.Varchar2,this.LEADUNITPARENT, ParameterDirection.Input),
                         new OracleParameter("LEADUNITPARENTNAME",OracleDbType.Varchar2,this.LEADUNITPARENTNAME, ParameterDirection.Input),
                         new OracleParameter("SPONSORNAME",OracleDbType.Varchar2,this.SPONSORNAME, ParameterDirection.Input),
                         new OracleParameter("PROPOSALCOST",OracleDbType.Double,this.PROPOSALCOST, ParameterDirection.Input),
                         para_submitdate,
                         para_startdate,
                         para_enddate
                  };

                Database dm_import_recs = new Database();
                bool insert_rsult = dm_import_recs.RunOracleCommandWithParams(proposalRecordInsert, parameters);
                dm_import_recs.Close();

                foreach (OracleParameter pa in parameters)
                {
                    pa.Dispose();
                }
                return insert_rsult;
            }
            catch (Exception e)
            {
                throw new Exception("insert error for proposal " + this.PROPOSALID + ". Error message " + e.Message);
            }
        }
    }

    public class ErrorRecord
    {
        public string LINENUMBER { get; set; }
        public string ERRORMESSAGE { get; set; }
        public string ERRORDATA { get; set; }
        public string ERRORCODE { get; set; }
    }
}
