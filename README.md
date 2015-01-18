CordovaSQLite
=============

A custom plugin for accessing SQLite databases through Cordova. The plugin API is different from the WebSQL API that is used in other plugins.

## Installation

Use cordova CLI to install the plugin:
> cordova plugin add net.orworks.cordovaplugins.cordovasqlite <br />
> OR, cordova plugin add https://github.com/samikrc/CordovaSQLite.git

## Uninstallation

Use cordova CLI to uninstall the plugin:
> cordova plugin rm net.orworks.cordovaplugins.cordovasqlite

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
