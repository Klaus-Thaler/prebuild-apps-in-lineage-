# prebuild-apps-in-lineage-
This script builds in custom apps on the fly while compiling lineage. The apps are currently downloaded from the repo.

Here in this script:
- Bromite WebView (Subsystem)
- Bromite Browser (HTML-Viewer)
- Neo-Storer (F-Droid Client)
- DavX (CalDAV/CardDAV-Sync)
- NewPipe (U-Tube)
- (insert your favorite app here) ;-)

Copy this script in your lineage repo dir "lineage_build_unified" and link this in file "buildbot_unified.sh", function "build_treble" after "lunch ...".

https://github.com/AndyCGYan/lineage_build_unified

Special thanks to https://github.com/AndyCGYan
