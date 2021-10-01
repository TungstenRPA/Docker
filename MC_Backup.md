# MC Backup file
The MC Docker instance will restore a backup to configure the MC to be ready for use. It does the following.  
## Create Users and Groups
* Create Groups "Roboservers", "KappletAdmins", "KappletUsers", "Synchronizers", "Developers"
* Create user "Synchronizer" in group "Synchronizers"
## Configure Non Production Cluster
* Add postgres Database with name **postgres** **(currently pointing at scheduler)**
## Configure Databases
* Disable sending databases to Design Studio  
*for this release, the user will use development database in Design Studio, and the robot will use a database mapping to use postgres. Design Studio CANNOT see the postgres CONTAINER and MC & Roboserver CANNOT see development database*
## Configure Default Project
* Create Role-Group matchings for "Roboservers", "KappletAdmins", "KappletUsers", "Synchronizers", "Developers"
## Configure Robots
* upload robot "NewsMagazine.robot" and type "Post.type"
## Configure Kapplets
* ??
## What is not included
* A human developer account is not included. that is added to MC after the restore
* the roboserver user is added after the restore.

## To do later
* have more databases in postgres container: **scheduler**, **robot_data**, **logs**, **kapplets**, **audit**
