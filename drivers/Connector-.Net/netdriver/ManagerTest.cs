﻿/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace netdriver
{
    class ManagerTest
    {
        public static void MTest(string dblemanagerconnStr, List<String> Msqlfiles, String logpath)
        {
            MySqlConnection dblemanagerconn = Conn.MySQLConn(dblemanagerconnStr);
            if (dblemanagerconn != null)
            {
                for (int i = 0; i < Msqlfiles.Count; i++)
                {
                    //create log files as per the name of sql file
                    String sqlpath = Msqlfiles[i];
                    String sqlfilename = Path.GetFileNameWithoutExtension(sqlpath);
                    String passlogname = sqlfilename + "_pass.log";
                    String faillogname = sqlfilename + "_fail.log";
                    String[] logfilenames = { passlogname, faillogname };
                    String[] logfiles = CreateFile.CreateFiles(logpath, logfilenames,false);

                    ExecuteManager.Execute(Msqlfiles[i], logfiles, dblemanagerconn);
                }
                //close db connection
                CleanUp.CloseConnection(dblemanagerconn);
            }
        }
    }
}