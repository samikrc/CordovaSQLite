/** 
 * This file contain a proxy for the SQLite functionality in a browser environment.
 * Only tested in FireFox browsers, with the "HTML5 WebSQL for Firefox" plugin v0.6.
 * Notes: 
 * - All the methods in this file are to be written as fn(successCallback, errorCallback, args),
 *   where 'successCallback', 'errorCallback' are functions and 'args' is an array of arguments.
 */

module.exports = 
{
    /** 
     * Web database.
     */
    webDB: null,

	/**
	 * Indicates if the database is initialized.
	 */
	dbInitialized: false,
	
    /**
    * Method to open a database.
    * @param successCallback The callback which will be called when database is opened successfully.
    * @param failureCallback The callback which will be called when database can't be opened.
	* @param args Argument array. 0: Full path to the database file, 1: To create the database (true/false).
    */
    openDatabase: function (successCallback, errorCallback, args)
    {
		// Get arguments.
		var fullPath = args[0];
		var toCreate = args[1];
		
		// In browser environment, typically we will get fullPath as "/xxx.sqlite". Just extract the
		// filename from the fullPath variable and save it in fullPath.
		fullPath = /[^.]+/.exec(fullPath)[0].substr(1);
		
		console.log("Opening SQLite database: " + fullPath);
		var thisObj = this;
        if (!this.dbInitialized)
        {
			try
			{
				this.webDB = window.openDatabase(fullPath, "1.0", "Session DB", 2 * 1024 * 1024);
				console.log("  ** Database file is now available. Populate database offline or through API if required.");
				successCallback();
			}
			catch(err)
			{	errorCallback(err);	}				
        }
    },

    /**
    * Executes a query and return a single string. Note: number is returned as string 
    * and have to eval()-ed before using.
    * @param successCallback The callback which will be called when the query is executed successfully.
    * @param failureCallback The callback which will be called when the query can't be executed.
	* @param args Argument array. 0: SQL string, 1: An array of parameters.
    */
    execQuerySingleResult: function (successCallback, errorCallback, args)
    {
 		// Get arguments.
		var sql = args[0];
		var params = args[1];

		var database = this.webDB;
        database.transaction(
        function (tx)
        {
            console.log("Executing: " + sql + ", parms: " + params.toString());
            tx.executeSql(sql, params,
            function (tx, results)
            {
                var result = null;
                if (results.rows.length > 0)
                {
                    // Get the set of columns.
                    var cols = Object.keys(results.rows[0]);
                    result = results.rows[0][cols[0]];
                    console.log("For query: " + sql + ", parms: " + params.toString() + ", result: " + result);
                }
                // Now call the success callback.
                if(successCallback != null)
                    successCallback(result);
            }, null);
        });
    },

    /**
    * Executes a query and return a 2D javascript array. Rows are records and columns are data cols.
    * Note: numbers are returned as strings in the array and have to eval()-ed before using.
    * @param successCallback The callback which will be called when the query is executed successfully.
    * @param failureCallback The callback which will be called when the query can't be executed.
	* @param args Argument array. 0: SQL string, 1: An array of parameters.
    */
    execQueryArrayResult: function (successCallback, errorCallback, args)
    {
		// Get arguments.
		var sql = args[0];
		var params = args[1];

        var database = this.webDB;
        database.transaction(
        function (tx)
        {
            console.log("Executing: " + sql + ", parms: " + params.toString());
            tx.executeSql(sql, params,
            function (tx, results)
            {
                var resultSet = [];
                if(results.rows.length > 0)
                {
                    console.log("For query: " + sql + ", parms: " + params.toString() + ", result length = " + results.rows.length);
                    // Get the set of columns.
                    var cols = Object.keys(results.rows[0]);
                    // Now go through result rows
                    for (var i = 0; i < results.rows.length; i++)
                    {
                        var row = [];
                        cols.forEach(function (col)
                        { row.push(results.rows[i][col]); });
                        resultSet.push(row);
                    }
                }
                // Now call the success callback.
                if (successCallback != null)
                    successCallback(resultSet);
            }, null);
        });
    },

    /**
    * Executes a bunch of queries, which doesn't return any result.
    * @param successCallback The callback which will be called when queries are executed successfully.
    * @param failureCallback The callback which will be called when queries couldn't be executed.
	* @param args Argument array. 0: An array of SQL statements
     *        Example: ["DROP TABLE IF EXISTS DEMO",
    *                   "CREATE TABLE IF NOT EXISTS DEMO (id unique, data)",
    *                   "INSERT INTO DEMO (id, data) VALUES (1, 'First row')",
    *                   "INSERT INTO DEMO (id, data) VALUES (2, 'Second row')"];
   */
    execQueryNoResult: function (successCallback, errorCallback, args)
    {
		// Get arguments.
		var sqlStatements = args[0];
		
        var database = this.webDB;
        database.transaction(
        function (tx)
        {
            for (var i = 0; i < sqlStatements.length; i++)
            {
                console.log("Executing: " + sqlStatements[i]);
                tx.executeSql(sqlStatements[i]);
            }
        });

        if(successCallback != null)
            successCallback();
    },

    /**
    * Closes a database safely.
    */
    closeDB: function ()
    {
        
    },

    /*
     * Method to print the query result. 
     * Can be used from console prompt when debugging like so: 
     *      SQLiteShell.execQueryArrayResult("select * from allevents where DayID=?", ["D01"], SQLiteShell.printResult, null);
     */
    printResult: function (queryResult)
    {
        // Check if the query result is an array.
        // Reference: http://stackoverflow.com/questions/4775722/check-if-object-is-array
        queryResult = [].concat(queryResult);
        var resultStr = "";
        queryResult.forEach(function (val)
        { 	resultStr += val + ", "; 	});
        resultStr = resultStr.substring(0, resultStr.lastIndexOf(','));
        console.log("Query result: " + resultStr);
    },

    /**
     * Prints the list of tables in the database.
     */
    listTables: function()
    {
        this.execQueryArrayResult(this.printResult, null, ["select name from sqlite_master where type=? order by name", ["table"]]);
    },

    /**
     * Prints row count of the table.
     * @param table: Table name
     */
    listTableEntryCount: function(table)
    {
        this.execQuerySingleResult(null, null, ["select count(*) from " + table, []]);
    }
	
};

require("cordova/exec/proxy").add("CordovaSQLite", module.exports);
 
