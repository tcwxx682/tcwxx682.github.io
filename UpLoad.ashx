<%@ WebHandler Language="C#" Class="UpLoad" Debug="true" %>

using System;
using System.Web;
using System.Data;
using System.IO;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;

public class UpLoad : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        HttpPostedFile fileinfo = context.Request.Files[0];
        string randomStr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        string outPass = GetDownloadCode(fileinfo.FileName + fileinfo.InputStream.Length.ToString() + fileinfo.InputStream.GetHashCode().ToString());

        int intCount = new Random().Next(1, 10);
        for (int i = 0; i < intCount; i++)
        {
            int intStart = new Random().Next(1, 61);
            string strSub = randomStr.Substring(intStart, 1);
            int intSert = new Random().Next(1, outPass.Length);
            outPass.Insert(intSert, strSub);
        }

        string DownLoadCode = MD5(outPass);

        fileinfo.SaveAs(@"G:\filePath\" + fileinfo.FileName + "-temp#" + DownLoadCode);
        context.Response.ContentType = "text/plain";
        context.Response.Write("{\"DownLoadCode\":\"" + GetDownloadCode(DownLoadCode) + "\"}");
    }

    private string GetDownloadCode(string fileName)
    {
        string OUTPASS = "";
        string SORCE_STRING = "AVWXxyQF48GCMNzPIJOSTUlm12u567vwDoEnYZabcKL3defghHBijktR0pqrs9";
        string DEST_STRING = "48xyQFJOSGCMNXVW2Lzrsktdeu5671oEnYZabcKfgIADvijHBqR0pP3wTUlmh9";
        string timeStr = DateTime.Now.ToString();
        int OFFSET = Convert.ToInt32(timeStr.Substring(timeStr.Length - 2, 2));
        int OFFSET2 = new Random().Next(1, 61);
        string TEMP1 = (SORCE_STRING + SORCE_STRING).Substring(OFFSET - 1, 62);
        string TEMP2 = (DEST_STRING + DEST_STRING).Substring(OFFSET2 - 1, 62);
        for (int i = 0; i < fileName.Length; i++)
        {
            string C = fileName.Substring(i, 1);
            int J = TEMP1.IndexOf(C) + 1;
            if (J == 0)
                OUTPASS += C;
            else
                OUTPASS += TEMP2.Substring(J - 1, 1);
        }

        return SORCE_STRING.Substring(OFFSET - 1, 1) + SORCE_STRING.Substring(OFFSET2 - 1, 1) + OUTPASS;
    }

    /// <summary>
    /// MD5加密字符串
    /// </summary>
    /// <param name="PassWord"></param>
    /// <returns></returns>
    private static string MD5(string PassWord)
    {
        byte[] result = Encoding.Default.GetBytes(PassWord);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] output = md5.ComputeHash(result);
        return BitConverter.ToString(output).Replace("-", "");
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}