using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Configuration;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;

namespace risdashupload
{
    public class Database
    {
        public static string connectionstr;
        public static OracleConnection oraConnection;

        public List<ProcParam> procParams { get; set; }
        public DataSet daResult { get; set; }

        public Database()
        {
            connectionstr = ConfigurationManager.AppSettings["OracleConnectionString"];
            oraConnection = new OracleConnection(connectionstr);
            procParams = new List<ProcParam>();
            daResult = new DataSet();
        }

        public bool getProcedureData(string querystr)
        {
            OracleCommand cmd = new OracleCommand(querystr);
            string output_table = "";
            bool result = false;

            //using (oraConnection)
            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.StoredProcedure;

                foreach (ProcParam ppm in procParams)
                {
                    if (ppm.ParamType == "CHAR" && ppm.Direction == "IN")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Char, ppm.ParamValue, ParameterDirection.Input);
                    }
                    else if (ppm.ParamType == "NUMBER" && ppm.Direction == "IN")
                    {
                        short v_param = 0;
                        if (System.Int16.TryParse(ppm.ParamValue, out v_param))
                        {
                            cmd.Parameters.Add(ppm.ParamName, OracleDbType.Decimal, v_param, ParameterDirection.Input);
                        }
                        else
                        {
                            throw new Exception("Procedure Parameter type is wrong. Parameter " + ppm.ParamValue + " should be number.");
                        }

                    }
                    else if (ppm.ParamType == "NVarChar" && ppm.Direction == "IN")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Varchar2, ppm.ParamValue, ParameterDirection.Input);
                    }
                    else if (ppm.Direction == "OUT")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                        output_table = ppm.ParamName;
                    }
                    else
                    {
                        throw new Exception("Procedure Parameter type is wrong");
                    }
                }

                oraConnection.Open();
                // get data from Banner
                OracleDataAdapter oracleDataApt = new OracleDataAdapter(cmd);
                oracleDataApt.TableMappings.Add("Table", output_table);
                oracleDataApt.Fill(daResult);
                oraConnection.Close();
                result = true;
            }
            catch (Exception e)
            {
                string message = e.Message;
                throw new Exception(message);
            }
            return result;
        }

        public bool executeProcedureWithoutOutput(string querystr)
        {
            OracleCommand cmd = new OracleCommand(querystr);
            bool result = false;

            //using (oraConnection)
            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.StoredProcedure;

                foreach (ProcParam ppm in procParams)
                {
                    if (ppm.ParamType == "CHAR" && ppm.Direction == "IN")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Char, ppm.ParamValue, ParameterDirection.Input);
                    }
                    else if (ppm.ParamType == "NUMBER" && ppm.Direction == "IN")
                    {
                        short v_param = 0;
                        if (System.Int16.TryParse(ppm.ParamValue, out v_param))
                        {
                            cmd.Parameters.Add(ppm.ParamName, OracleDbType.Decimal, v_param, ParameterDirection.Input);
                        }
                        else
                        {
                            throw new Exception("Procedure Parameter type is wrong. Parameter " + ppm.ParamValue + " should be number.");
                        }

                    }
                    else if (ppm.ParamType == "NVarChar" && ppm.Direction == "IN")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Varchar2, 500).Value = ppm.ParamValue;
                        cmd.Parameters[ppm.ParamName].Direction = ParameterDirection.Input;
                    }
                    else if (ppm.ParamType == "CHAR" && ppm.Direction == "OUT")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Char, ppm.ParamValue, ParameterDirection.Output);
                    }
                    else if (ppm.ParamType == "NUMBER" && ppm.Direction == "OUT")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Decimal, ppm.ParamValue, ParameterDirection.Output);
                    }
                    else if (ppm.ParamType == "NVarChar" && ppm.Direction == "OUT")
                    {
                        cmd.Parameters.Add(ppm.ParamName, OracleDbType.Varchar2, 500).Value = ppm.ParamValue;
                        cmd.Parameters[ppm.ParamName].Direction = ParameterDirection.Output;
                    }
                    else
                    {
                        throw new Exception("Procedure Parameter type is wrong");
                    }
                }

                // execute procedure
                oraConnection.Open();
                cmd.ExecuteNonQuery();
                oraConnection.Close();

                if (cmd.Parameters["v_strflag"].Value.ToString() == "1")
                {
                    result = true;
                }
                else
                {
                    string message = cmd.Parameters["v_strOutput"].Value.ToString();
                    throw new Exception(message);
                }
            }
            catch (Exception e)
            {
                string message = e.Message;
                throw new Exception(message);
            }
            return result;
        }

        public bool getSelectData(string querystr)
        {
            OracleCommand cmd = new OracleCommand(querystr);
            bool result = false;

            //using (oraConnection)
            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.Text;
                oraConnection.Open();

                OracleDataAdapter oracleDataApt = new OracleDataAdapter();
                oracleDataApt.SelectCommand = cmd;
                oracleDataApt.Fill(daResult);
                oraConnection.Close();
                result = true;
            }
            catch (Exception e)
            {
                string message = e.Message;
                throw new Exception(message);
            }
            return result;
        }
        public bool getSelectData(string querystr, OracleParameter[] myParamArray)
        {
            OracleCommand cmd = new OracleCommand(querystr);
            bool result = false;

            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.Text;
                oraConnection.Open();

                for (int i = 0; i < myParamArray.Length; i++)
                    cmd.Parameters.Add(myParamArray[i]);

                OracleDataAdapter oracleDataApt = new OracleDataAdapter();
                oracleDataApt.SelectCommand = cmd;
                oracleDataApt.Fill(daResult);
                oraConnection.Close();
                result = true;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            return result;
        }
        public bool InsertData(string querystr)
        {
            OracleCommand cmd = new OracleCommand(querystr);
            bool result = false;

            //using (oraConnection)
            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.Text;
                oraConnection.Open();

                OracleDataAdapter oracleDataApt = new OracleDataAdapter();
                oracleDataApt.SelectCommand = cmd;
                oracleDataApt.Fill(daResult);
                oraConnection.Close();
                result = true;
            }
            catch (Exception e)
            {
                string message = e.Message;
                throw new Exception(message);
            }
            return result;
        }

        public bool runOracleCommand(string querystr)
        {
            OracleCommand cmd = new OracleCommand(querystr);
            bool result = false;

            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.Text;
                oraConnection.Open();
                cmd.ExecuteNonQuery();
                oraConnection.Close();
                result = true;
            }
            catch (Exception e)
            {
                string message = e.Message;
                throw new Exception(message);
            }
            return result;
        }

        public bool RunOracleCommandWithParams(string queryString, OracleParameter[] myParamArray)
        {
            OracleCommand cmd = new OracleCommand();
            bool result = false;

            try
            {
                cmd.Connection = oraConnection;
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = queryString;

                for (int i = 0; i < myParamArray.Length; i++)
                    cmd.Parameters.Add(myParamArray[i]);

                oraConnection.Open();
                cmd.ExecuteNonQuery();
                cmd.Parameters.Clear();
                oraConnection.Close();

                result = true;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            return result;
        }

        public void ResetExecution()
        {
            if (procParams != null) { procParams.Clear(); }
            if (daResult != null) { daResult.Clear(); }
        }

        public void Close()
        {
            if (oraConnection != null) { oraConnection.Close(); }
            if (procParams != null) { procParams.Clear(); }
            if (daResult != null) { daResult.Clear(); }

        }
    }
    public class ProcParam
    {
        public String ParamName { get; set; }
        public String ParamValue { get; set; }
        public String ParamType { get; set; }
        public String Direction { get; set; }

        public ProcParam(String pName, String pValue, String pType, String pDirection)
        {
            this.ParamName = pName;
            this.ParamValue = pValue;
            this.ParamType = pType;
            this.Direction = pDirection;
        }

    }
}
