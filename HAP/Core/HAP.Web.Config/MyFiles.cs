﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Web;

namespace HAP.Web.Configuration
{
    public class MyFiles
    {
        private XmlDocument doc;
        public MyFiles(ref XmlDocument doc)
        {
            this.doc = doc;
            if (doc.SelectSingleNode("/hapConfig/myfiles") == null) Initialize();
            KnownIcons = new XmlDocument();
            KnownIcons.Load(HttpContext.Current.Server.MapPath("~/Images/Icons/KnownIcons.xml"));
        }

        public Filters Filters { get { return new Filters(ref doc); } }
        public DriveMappings Mappings { get { return new DriveMappings(ref doc); } }
        public QuotaServers QuotaServers { get { return new QuotaServers(ref doc); } }
        public XmlDocument KnownIcons { get; private set; }
        public string LiveAppId
        {
            get { return doc.SelectSingleNode("/hapConfig/myfiles").Attributes["LiveAppId"] == null ? "" : doc.SelectSingleNode("/hapConfig/myfiles").Attributes["LiveAppId"].Value; } 
            set 
            {
                if (doc.SelectSingleNode("/hapConfig/myfiles").Attributes["LiveAppId"] == null)
                    doc.SelectSingleNode("/hapConfig/myfiles").Attributes.Append(doc.CreateAttribute("LiveAppId"));
                doc.SelectSingleNode("/hapConfig/myfiles").Attributes["LiveAppId"].Value = value;
            }
        }
        public string HideExtensions 
        {
            get { return doc.SelectSingleNode("/hapConfig/myfiles").Attributes["hideextensions"].Value; }
            set { doc.SelectSingleNode("/hapConfig/myfiles").Attributes["hideextensions"].Value = value; } 
        }
        public bool WriteChecks 
        {
            get { return doc.SelectSingleNode("/hapConfig/myfiles").Attributes["writechecks"] == null ? true : bool.Parse(doc.SelectSingleNode("/hapConfig/myfiles").Attributes["writechecks"].Value); }
            set 
            {
                if (doc.SelectSingleNode("/hapConfig/myfiles").Attributes["writechecks"] == null)
                    doc.SelectSingleNode("/hapConfig/myfiles").Attributes.Append(doc.CreateAttribute("writechecks"));
                doc.SelectSingleNode("/hapConfig/myfiles").Attributes["writechecks"].Value = value.ToString();
            }
        }

        public void Initialize()
        {
            XmlElement e = doc.CreateElement("myfiles");
            e.SetAttribute("hideextensions", ".lnk,.ini");
            e.SetAttribute("writechecks", true.ToString());
            e.AppendChild(doc.CreateElement("mappings"));
            e.AppendChild(doc.CreateElement("filters"));
            e.AppendChild(doc.CreateElement("quotaservers"));
            doc.SelectSingleNode("/hapConfig").AppendChild(e);
            Filters.Add("Access Database", "*.mdb;*.accdb", "All");
            Filters.Add("Excel Documents", "*.xls;*.xlsx;*.xlt;*.xltx", "All");
            Filters.Add("HTML Files", "*.html;*.htm", "All");
            Filters.Add("Images", "*.jpg;*.gif;*.png;*.bmp;*.jpeg", "All");
            Filters.Add("Powerpoint Files", "*.ppt;*.pptx;*.pptx;*.ppt", "All");
            Filters.Add("Word Documents", "*.doc;*.docx;*.dotx;*.dot;*.txt;*.rtf;*.pdf", "All");
            Filters.Add("ZIP Files", "*.zip", "All");
            Filters.Add("All Files", "*.*", "Domain Admins");

        }
    }
}
