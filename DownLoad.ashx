<%@ WebHandler Language="C#" Class="DownLoad" Debug="true" %>

using System;
using System.Web;
using System.Data;
using System.IO;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;

public class DownLoad : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string strXZM = context.Request.Params["XZM"];
        string randomStr = DECODE(strXZM);
        DirectoryInfo dirInfo = new DirectoryInfo(@"G:\filePath");
        FileInfo[] files = dirInfo.GetFiles();
        string filename = "";
        string realName = "";
        foreach (FileInfo file in files)
        {
            string[] fileSplits = file.Name.Split(new string[] { "-temp#" }, StringSplitOptions.None);
            if (fileSplits.Length != 2)
                continue;
            if (randomStr.Equals(fileSplits[1]))
            {
                filename = file.FullName;
                realName = fileSplits[0];
            }
        }

        if (filename == "")
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"errMessage\":\"下载码不存在！\"}");
            return;
        }
        else
        {
            context.Response.Buffer = true;
            context.Response.Clear();
            context.Response.ContentType = "application/download";
            string downFile = System.IO.Path.GetFileName(realName);//这里也可以随便取名
            string EncodeFileName = HttpUtility.UrlEncode(downFile, Encoding.UTF8);//防止中文出现乱码
            context.Response.AddHeader("Content-Disposition", "attachment;filename=" + EncodeFileName + ";");
            context.Response.BinaryWrite(File.ReadAllBytes(filename));//返回文件数据给客户端下载
            context.Response.Flush();
            context.Response.End();
            File.Delete(filename);
        }

    }

    private string ENCODE(string fileName)
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

    private string DECODE(string fileName)
    {
        string OUTPASS = "";
        string SORCE_STRING = "AVWXxyQF48GCMNzPIJOSTUlm12u567vwDoEnYZabcKL3defghHBijktR0pqrs9";
        string DEST_STRING = "48xyQFJOSGCMNXVW2Lzrsktdeu5671oEnYZabcKfgIADvijHBqR0pP3wTUlmh9";
        string timeStr = DateTime.Now.ToString();
        int OFFSET = SORCE_STRING.IndexOf(fileName.Substring(0, 1)) + 1;
        int OFFSET2 = SORCE_STRING.IndexOf(fileName.Substring(1, 1)) + 1;
        string TEMP1 = (SORCE_STRING + SORCE_STRING).Substring(OFFSET - 1, 62);
        string TEMP2 = (DEST_STRING + DEST_STRING).Substring(OFFSET2 - 1, 62);
        for (int i = 2; i < fileName.Length; i++)
        {
            string C = fileName.Substring(i, 1);
            int J = TEMP2.IndexOf(C) + 1;
            if (J == 0)
                OUTPASS += C;
            else
                OUTPASS += TEMP1.Substring(J - 1, 1);
        }

        return OUTPASS;
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