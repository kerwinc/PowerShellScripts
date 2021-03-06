# Handy PowerShell Scripts

So how many times do you write a PowerShell CmdLet for a project, forget about it, go hunt for it a few weeks later then end up writing it from scratch again... This happens to me all the time so this PowerShell repo is going to serve as a handy hub for all functions I write for automation.

***
***Web Administration Extensions***

This module has a few of handy CmdLet wrappers for managing WebSites and WebApplications. Here is brief overview of the public functions:

- **Get-SiteAppPool**: Gets a site's application pool for a website or webapplication.

- **Get-SitePhysicalPath**: Gets a site's physical path for a website or webapplication.

- **Test-AppPoolExists**: Tests if an application pool exists. Returns a boolean value.

- **Test-SiteExists**: Tests if a website or webapplication exists. Returns a boolean value.

- **Set-SitePhysicalPath**: Changes a website or web application's physical path.

- **Start-WebApplicationPool**: Starts a application pool and waits for the application pool's state to change.

- **Stop-WebApplicationPool**: Stops a application pool and waits for the application pool's state to change.

- **Publish-WebSite**: This function allows you to publish a folder's contents to a web site or web application by name. It looks up the site's physical path, application pool during the publish.

- **Backup-WebSite**: Looks up a website or web application's physical path and creates a {WebSiteName_DateTime}.Zip archive to the desired directory.

- **Restore-WebSite**: Restores a web site or web application's artifacts from a .zip file.

- **New-IISWebSite**: Creates a new IIS web site, application pool and physical path if desired.

- **New-IISWebApplication**: Creates a new IIS web application, application pool and physical path if desired.

***

***File Extensions***

This module has a few of handy CmdLet wrappers for managing files and folders. Here is brief overview of the public functions:

- **Copy-DirectoryContents**: Copies all child items 
from a source directory to a destination directory recursively.

- **Copy-Directory**: Copies a folder to a destination directory recursively.

- **New-Directory**: Creates a new directory.

- **Remove-DirectoryContents**: Safely removes all 
items in the specified directory.

- **Remove-Directory**: Safely removes a directory.

- **ZipFiles**: Creates a .zip archive with optimal compression and saves the archive in the specified directory.

- **ExtractZipFile**: Extracts a .zip archive to the specified directory. Note: It does not remove any items from the destination directory.

***XML Transform Extensions***

This module provides a way to transform configuration files using Microsoft's transform DLL. The Visual Studio 2017 version has been included in the lib directory.

- **Invoke-XmlTransform**: Transforms a config files using an XDT transform file.

*I will be adding Pester tests in the near future...*