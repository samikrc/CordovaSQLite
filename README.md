CordovaSQLite
=============

A custom plugin for accessing SQLite databases through Cordova. The plugin API is different from the WebSQL API that is used in other plugins.

## Installation

Use cordova CLI to install the plugin:
    cordova plugin add https://github.com/samikrc/CordovaSQLite.git

## Uninstallation

Use cordova CLI to uninstall the plugin:
    cordova plugin rm net.orworks.cordovaplugins.cordovasqlite

## Platform Notes

### iOS

For iOS platform, after you add the plugin, you will also have to add "libsqlite3.0.dylib" for linking. To do that, perform the following:
- Click on the project name on the left pane in XCode. That would load the project configurations.
- Click on the 'Build Phases' tab. Next select 'Link Binary With Libraries'
- Click the '+' icon to add a library. In the dialog box that appears, search for sqlite and select "libsqlite3.0.dylib".
