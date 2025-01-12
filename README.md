SlackBuilds
------------------

All packages tested on -current(post 15.0) version


0. Install [slapt-src](http://software.jaos.org/#slapt-src)
1. Add source to */etc/slapt-get/slapt-srcrc*

           SOURCE=https://slackware.rpz.name/
           
2. Use *slapt-src* for build and install packages, ex:

           #slapt-src --update
           #slapt-src --install phpstorm

