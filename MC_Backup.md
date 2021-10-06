# MC Backup file
The MC Docker instance will restore a backup to configure the MC to be ready for use. It does the following.  
## Create Users and Groups
* Create Groups "Roboservers", "KappletAdmins", "KappletUsers", "Synchronizers", "Developers"
## Configure Non Production Cluster
* Remove any Roboservers from cluster (as ip address invalid)
* Add postgres Database with name **PostgreSQL** **(currently pointing at scheduler)**
## Configure Databases
* Add database mapping so that demo robot can log to database.
  * **objectdb**, **Default Project**, **Non Production**, **PostgreSQL**
* Disable sending databases to Design Studio in **Settings/DesignStudio**  
*for this release, the user will use development database in Design Studio, and the robot will use a database mapping to use postgres. Design Studio CANNOT see the postgres CONTAINER and MC & Roboserver CANNOT see development database, so it makes no sense for MC to send database drivers to Design Studio.*
## Configure Default Project
* Create Role-Group matchings for "Roboservers", "KappletAdmins", "KappletUsers", "Synchronizers", "Developers"
* Make sure is using **Non Production** cluster.
## Configure Robots
* upload robot "NewsMagazine.robot" and type "Post.type"
## Configure Kapplets
* ??
## What is not included
* Users are added after restore to set names & passwords
  * A human developer account.
  * the roboserver user. roboserver won't start up until this account exists as roboserver gives up after logging in fails twice
  *  user "Synchronizer" in group "Synchronizers"

## To do later
* have more databases in postgres container: **scheduler**, **robot_data**, **logs**, **kapplets**, **audit**
