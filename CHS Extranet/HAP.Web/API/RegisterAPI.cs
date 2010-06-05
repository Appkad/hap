﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;

namespace HAP.Web.API
{
    public class APIRoutes
    {
        public static void Register(RouteCollection collection)
        {
            RouteTable.Routes.Add(new Route("api/mycomputer/listdrives", new ListDrivesHandler()));
            RouteTable.Routes.Add(new Route("api/mycomputer/list/{*path}", new ListHandler()));
        }
    }
}