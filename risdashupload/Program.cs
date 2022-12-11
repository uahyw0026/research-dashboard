using System;
using Serilog;
using Serilog.Events;
using System.IO;
using System.Configuration;

namespace risdashupload
{
    class Program
    {
        static void Main(string[] args)
        {
            string fodler = ConfigurationManager.AppSettings["LogFolder"];
            string uploadlog = ConfigurationManager.AppSettings["UploadLogFile"];


            Log.Logger = new LoggerConfiguration()
                  .MinimumLevel.Debug()
                  .WriteTo.File(fodler + uploadlog, rollingInterval: RollingInterval.Day)
                  .WriteTo.Console(restrictedToMinimumLevel: LogEventLevel.Information)
                  .CreateLogger();
            try
            {
                string importuser = ConfigurationManager.AppSettings["ImportUser"];
                string uploadfodler = ConfigurationManager.AppSettings["UploadFolder"];
                string proposalfile = ConfigurationManager.AppSettings["ProposalFile"];
                int proposal_columns = Int32.Parse(ConfigurationManager.AppSettings["ProposalFileColumns"].ToString());
                string awardfile = ConfigurationManager.AppSettings["AwardFile"];
                int award_columns = Int32.Parse(ConfigurationManager.AppSettings["AwardFileColumns"].ToString());

                if (File.Exists(uploadfodler+proposalfile))
                {
                    Log.Information(DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString() + " Uploading Proposal file" + uploadfodler + proposalfile);
                    ProposalRecords propRcds = new ProposalRecords();
                    bool result = propRcds.populateProposalRecords(uploadfodler + proposalfile, importuser);

                    if(result)
                        Log.Information(DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString() + " Proposal file" + uploadfodler + proposalfile + " is upload successfully");
                    else
                        Log.Error(DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString() + " Proposal file" + uploadfodler + proposalfile + " upload failure. Error message is " + propRcds.error_message);
                }
                else
                {
                    throw new Exception("Propsal file " + uploadfodler + proposalfile + " does not exist");
                }
                
                //Console.WriteLine("Hello World!");
                //Console.ReadKey();
            }
            catch (Exception ex)
            {
                Log.Fatal(ex, "Application start-up failed. Error Message is " + ex.Message);
            }
            finally
            {
                Log.CloseAndFlush();
            }
        }
    }
}
