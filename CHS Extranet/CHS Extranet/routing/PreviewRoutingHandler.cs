﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Security;
using System.Web.Compilation;
using System.Net;
using System.Web.UI;

namespace CHS_Extranet.routing
{
    public class PreviewRoutingHandler : IRouteHandler
    {
        public PreviewRoutingHandler()
        {
        }

        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            string path = requestContext.RouteData.Values["path"] as string;
            if (path.EndsWith(".docx"))
            {
                DocXPreviewHandler docx = new DocXPreviewHandler();
                docx.RoutingPath = path;
                docx.RoutingDrive = requestContext.RouteData.Values["drive"] as string;
                docx.RoutingDrive = docx.RoutingDrive.ToUpper();
                return docx;
            }
            else
            {
                if (!UrlAuthorizationModule.CheckUrlAccessForPrincipal("~/xls.aspx", requestContext.HttpContext.User, requestContext.HttpContext.Request.HttpMethod))
                {
                    requestContext.HttpContext.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                    requestContext.HttpContext.Response.End();
                }

                IMyComputerDisplay display = BuildManager.CreateInstanceFromVirtualPath("~/xls.aspx", typeof(Page)) as IMyComputerDisplay;
                if (requestContext.RouteData.Values.ContainsKey("path")) display.RoutingPath = requestContext.RouteData.Values["path"] as string;
                else display.RoutingPath = string.Empty;
                display.RoutingDrive = requestContext.RouteData.Values["drive"] as string;
                display.RoutingDrive = display.RoutingDrive.ToUpper();

                return display;
            }
        }
    }
}