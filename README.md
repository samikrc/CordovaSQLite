CordovaSQLite
=============

A custom plugin for accessing SQLite databases through Cordova. The plugin API is different from the WebSQL API that is used in other plugins.

## Installation

Use cordova CLI to install the plugin:
<pre>
> cordova plugin add net.orworks.cordovaplugins.cordovasqlite
> OR, cordova plugin add https://github.com/samikrc/CordovaSQLite.git
</pre>

## Uninstallation

Use cordova CLI to uninstall the plugin:
<pre>
> cordova plugin rm net.orworks.cordovaplugins.cordovasqlite
</pre>

## API

The API contains the following functions:
- openDatabase(fullPath, toCreate, successCallback, errorCallback): Method to open a database.
  - fullPath: Full path to the database file.
  - toCreate: Whether to create the database if it does not exist.
  - successCallback
  - errorCallback
- execQuerySingleResult(sql, params, successCallback, errorCallback): Executes a query and returns a single string. Note: number is returned as string and have to eval()-ed before using.
  - sql: SQL string.
  - params: An array of parameters, to be used for binding with the SQL string.
  - successCallback
  - errorCallback
- execQueryArrayResult(sql, params, successCallback, errorCallback): Executes a query and returns a 2D javascript array. Rows are records and columns are data cols. Note: number is returned as string and have to eval()-ed before using.
  - sql: SQL string.
  - params: An array of parameters, to be used for binding with the SQL string.
  - successCallback
  - errorCallback
- execQueryNoResult(sqlStatements, successCallback, errorCallback): Executes a bunch of queries, which doesn't return any result.
  - sqlStatements: Array containing sql statements like INSERT, UPDATE, DELETE. No provision for providing binding parameters here, so parameters have to be embedded in the query string itself, if required.
  - successCallback
  - errorCallback
- closeDB(): Closes a database connection safely.

## Sample Code

The following code assumes an existing database file. Creating a new database file with some data would work the same way. 

<pre>
window.resolveLocalFileSystemURL(cordova.file.externalDataDirectory,
function (confDir)
{
	console.log("Got directory: " + confDir.fullPath);
	var dbFullPath = cordova.file.externalDataDirectory + "2014110801.sqlite";
	confDir.getFile("2014110801.sqlite", { create: false },
	function (confFile)
	{
		console.log("Got file: " + confFile.fullPath);
		cordovaSQLite.openDatabase(dbFullPath, false,
		function ()
		{
			cordovaSQLite.execQueryArrayResult("select value from info where name=?", ["Conference"],
			function (confName)
			{   console.log("Got conference name: " + confName);   },
			function (error) { alert("##execQueryArrayResult: " + error); });
		 },
		 function (error) { alert("##openDatabase: " + error); });
	},
	function (error) { alert("##getFile: " + error); });
}, // Success callback [resolveLocalFileSystemURL]
function (error) { alert(error); }); // Failure callback [resolveLocalFileSystemURL]
</pre>

## Platform Notes

### iOS

For iOS platform, after you add the plugin, you will also have to add "libsqlite3.0.dylib" for linking. To do that, perform the following:
- Click on the project name on the left pane in XCode. That would load the project configurations.
- Click on the 'Build Phases' tab. Next select 'Link Binary With Libraries'
- Click the '+' icon to add a library. In the dialog box that appears, search for sqlite and select "libsqlite3.0.dylib".

### browser

One of the important aspect of developing apps with Cordova is that one should be able to test out the app completely from a browser environment, without having to build for a platform everytime. Unfortunately, many plugins lack the components for browser. This plugin can be tested out in a compatible browser environment. I have tested on Firefox (v34.0.5), but Chrome browser should work as well.

There are prerequisites to running the plugin in a browser environment. For FF:
- Install the "HTML5 WebSQL for Firefox" plugin v0.6. Can be found at: https://github.com/Sean-Der/WebSQL-For-FireFox
  - Restart the browser.
- Also, if you are using this plugin to interact with a SQLite file, you would presumably need the File plugin as well. Unfortunately, File plugin is not available for browser. You have to roll out your own version for the browser by looking at the existing plugins.

The databases will be available at the following locations: 
- Windows 7: %appdata%\Mozilla\Firefox\Profiles\xxxxxxxx.default\databases\file__
  - xxxxxxxx is the alpha-numeric key of the profile you are using in FF.

In order to use database in the browser for testing your app, follow one of the strategies below:
- Create a database file in the location (mentioned above), with the required data. The file must have '.sqlite' extension. Then configure the app and specify only the filename before extension as the 'database full path'.
- You can create the database from your app (and let the app show an error message the first time). Then browse to the folder and populate the database using command line tools before using it the next time.
