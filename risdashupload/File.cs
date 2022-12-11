using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.ComponentModel.DataAnnotations;

namespace risdashupload
{
    /// <summary>
    /// Class to store one CSV row
    /// </summary>
    public class CsvRow : List<string>
    {
        public string LineText { get; set; }
    }

    /// <summary>
    /// Class to write data to a CSV file
    /// </summary>
    public class CsvFileWriter : StreamWriter
    {
        public CsvFileWriter(Stream stream)
            : base(stream)
        {
        }

        public CsvFileWriter(string filename)
            : base(filename)
        {
        }

        /// <summary>
        /// Writes a single row to a CSV file.
        /// </summary>
        /// <param name="row">The row to be written</param>
        public void WriteRow(CsvRow row)
        {
            StringBuilder builder = new StringBuilder();
            bool firstColumn = true;
            foreach (string value in row)
            {
                // Add separator if this isn't the first value
                if (!firstColumn)
                    builder.Append(',');
                // Implement special handling for values that contain comma or quote
                // Enclose in quotes and double up any double quotes
                if (value.IndexOfAny(new char[] { '"', ',' }) != -1)
                    builder.AppendFormat("\"{0}\"", value.Replace("\"", "\"\""));
                else
                    builder.Append(value);
                firstColumn = false;
            }
            row.LineText = builder.ToString();
            WriteLine(row.LineText);
        }
    }

    /// <summary>
    /// Class to read data from a CSV file
    /// </summary>
    public class CsvFileReader : StreamReader
    {
        public CsvFileReader(Stream stream)
            : base(stream)
        {
        }

        public CsvFileReader(string filename)
            : base(filename)
        {
        }

        /// <summary>
        /// Reads a row of data from a CSV file
        /// </summary>
        /// <param name="row"></param>
        /// <returns></returns>
        public bool ReadRow(CsvRow row)
        {
            row.LineText = ReadLine();
            if (String.IsNullOrEmpty(row.LineText))
                return false;

            int pos = 0;
            int rows = 0;

            while (pos < row.LineText.Length)
            {
                string value;

                // Special handling for quoted field
                if (row.LineText[pos] == '"')
                {
                    // Skip initial quote
                    pos++;

                    // Parse quoted value
                    int start = pos;
                    while (pos < row.LineText.Length)
                    {
                        // Test for quote character
                        if (row.LineText[pos] == '"')
                        {
                            // Found one
                            pos++;

                            // If two quotes together, keep one
                            // Otherwise, indicates end of value
                            if (pos >= row.LineText.Length || row.LineText[pos] != '"')
                            {
                                pos--;
                                break;
                            }
                        }
                        pos++;
                    }
                    value = row.LineText.Substring(start, pos - start);
                    value = value.Replace("\"\"", "\"");
                }
                else
                {
                    // Parse unquoted value
                    int start = pos;
                    while (pos < row.LineText.Length && row.LineText[pos] != ',')
                        pos++;
                    value = row.LineText.Substring(start, pos - start);
                }

                // Add field to list
                if (rows < row.Count)
                    row[rows] = value;
                else
                    row.Add(value);
                rows++;

                // Eat up to and including next comma
                while (pos < row.LineText.Length && row.LineText[pos] != ',')
                    pos++;
                if (pos < row.LineText.Length)
                    pos++;
            }
            // Delete any unused items
            while (row.Count > rows)
                row.RemoveAt(rows);

            // Return true if any columns read
            return (row.Count > 0);
        }
    }
    /// <summary>
    /// Class to read binary data from a pdf or image file
    /// </summary>
    public class BinaryFileReader
    {
        private string filename;
        private byte[] data;
        FileInfo fInfo;
        FileStream fStream;

        public BinaryFileReader(string v_filename)
        {
            filename = v_filename;
            data = null;
        }

        public byte[] ReadFile()
        {

            //Use FileInfo object to get file size.
            fInfo = new FileInfo(filename);
            long numBytes = fInfo.Length;

            //Open FileStream to read file
            fStream = new FileStream(filename, FileMode.Open, FileAccess.Read);

            //Use BinaryReader to read file stream into byte array.
            BinaryReader br = new BinaryReader(fStream);

            //When you use BinaryReader, you need to supply number of bytes to read from file.
            //In this case we want to read entire file. So supplying total number of bytes.
            data = br.ReadBytes((int)numBytes);
            return data;
        }


        public void close()
        {
            if (data != null)
                Array.Clear(data, 0, data.Length);

            if (fStream != null)
                fStream.Close();
        }

        public void delete()
        {
            try
            {
                if (data != null)
                    Array.Clear(data, 0, data.Length);

                if (fStream != null)
                    fStream.Close();

                if (System.IO.File.Exists(filename))
                {
                    System.IO.File.Delete(filename);
                }
            }
            catch (Exception e)
            {
                throw new Exception("Failed to Delete file " + this.filename + ". Error Message is " + e.Message);
            }
        }
    }
    public class Validator
    {
        private string dateRegularExpression = @"^(((((((0?[13578])|(1[02]))[\.\-/]?((0?[1-9])|([12]\d)|(3[01])))|(((0?[469])|(11))[\.\-/]?((0?[1-9])|([12]\d)|(30)))|((0?2)[\.\-/]?((0?[1-9])|(1\d)|(2[0-8]))))[\.\-/]?(((19)|(20))?([\d][\d]))))|((0?2)[\.\-/]?(29)[\.\-/]?(((19)|(20))?(([02468][048])|([13579][26])))))$";
        private string numberRegularExpression = @"^[0-9]+$";
        private string AnumberRegularExpression = @"^A[0-9]{8}$";
        private string decimalRegularExpression = @"^\d{1,15}(\.\d{1,2})?$";
        private string decimalRegularExpression100 = @"100.00|[1-9]?\d(\.\d{1,2})?";
        private string securityPermissionLevelRegularExpression = @"SCHOOL|DEPT";
        private string attachmentFileExtenstionRegularExpression = @"(.*?)\.(jpg|png|txt|gif|doc|docx|pdf)$";

        public bool IsValidEmail(string source)
        {
            return new EmailAddressAttribute().IsValid(source);
        }
        public bool IsRequired(string source)
        {
            return new RequiredAttribute().IsValid(source);
        }
        public bool IsDateType(string source)
        {
            RegularExpressionAttribute regExpAttr = new RegularExpressionAttribute(dateRegularExpression);
            return regExpAttr.IsValid(source);
        }
        public bool IsDecimalType(string source)
        {
            RegularExpressionAttribute regExpAttr = new RegularExpressionAttribute(decimalRegularExpression);
            return regExpAttr.IsValid(source);
        }
        public bool IsAllNumbers(string source)
        {
            RegularExpressionAttribute regExpAttr = new RegularExpressionAttribute(numberRegularExpression);
            return regExpAttr.IsValid(source);
        }
        public bool IsA_Number(string source)
        {
            RegularExpressionAttribute regExpAttr = new RegularExpressionAttribute(AnumberRegularExpression);
            return regExpAttr.IsValid(source);
        }
        public bool IsMaxLength(int len, string source)
        {
            MaxLengthAttribute maxLenAttr = new MaxLengthAttribute(len);
            return maxLenAttr.IsValid(source);
        }
        public bool IsMinimumLength(int len, string source)
        {
            MinLengthAttribute minLenAttr = new MinLengthAttribute(len);
            return minLenAttr.IsValid(source);
        }

        public bool IsAppropriateSecLevel(string source)
        {
            RegularExpressionAttribute regExpAttr = new RegularExpressionAttribute(securityPermissionLevelRegularExpression);
            return regExpAttr.IsValid(source);
        }
        public bool IsValidAttachmentExtension(string filename)
        {
            RegularExpressionAttribute regExpAttr = new RegularExpressionAttribute(this.attachmentFileExtenstionRegularExpression);
            return regExpAttr.IsValid(filename);
        }
    }
}