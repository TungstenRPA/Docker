# Kofax RPA and Docker.
Kofax RPA images are now published to [Docker Hub](https://hub.docker.com/u/kofax).  
Kofax RPA 11.3.0.0 and Kofax RPA 11.3.0.1 are available. Docker Kapplets currently does not work due to a log-in bug.  
* Install [RPA on Docker on Linux](#quick-start-guide-to-installing-kofax-rpa-on-docker-on-linux)
* Install [RPA on Docker on Synology NAS](Synology%20NAS)
## Quickstart Guide to installing Kofax RPA on Windows from Docker Hub 
1. Upgrade your Windows installation to the latest version, if you are using Windows 10. This will make the installation of Docker and Windows Subsystem for Linux (WSL2) easier.
2. Install **Windows Subsystem for Linux** by typing **wsl --install -d Ubuntu** at the command line. You may need to reboot afterwards. [Microsoft's Guide](https://docs.microsoft.com/en-us/windows/wsl/install).  
*You need no understanding of Linux or Ubuntu to work with Kofax RPA on Docker on Windows.*   
3. Enter a username and password for Ubuntu. (You won't need them). Close the Ubuntu window.
4.  Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/).
   - Select **Use WSL 2 instead of Hyper-V (recommended)**.
5. Get a [free Kofax RPA license](https://www.kofax.com/products/rpa/rpa-free-trial). You will have your license within 2 minutes.  
6. Download [docker-compose.yml](docker-compose.yml) from GitHub.  Click **Raw** and then Save the file.  
![image](https://user-images.githubusercontent.com/47416964/167140029-442922d9-fa48-447f-8094-d866c4eb5fff.png)

4. Create a folder on your computer and copy **docker-compose.yml** into it.  
![image](https://user-images.githubusercontent.com/47416964/167139416-fecbbed6-799b-43a7-a797-6cac9359a4ac.png)
5. Open Windows **Command Prompt** and change to your directory.  
![image](https://user-images.githubusercontent.com/47416964/167145058-2fe71f61-b141-4c92-a575-2b3d8dd0f10d.png)
6. Type  **docker compose -p kofaxrpa up**  
*-p sets the project name. Since Docker 2.5 a project name **must** be lowercase.*  
*This will download PostgreSQL databsae, KofaxRPA Management Console and Kofax RPA Roboserver from [Docker Hub](https://hub.docker.com/u/kofax) and then start all three running.*
8. Wait until Roboserver has started. *You will see further error messages from Management Console about a missing license. We will add that later.*   
![image](https://user-images.githubusercontent.com/47416964/167142680-fe3b0bb5-3010-49d8-97d0-a7d99e0360fa.png)
8. Open [Management Console](http://localhost:83) at http://localhost:83 and login with **admin/admin**.  
![image](https://user-images.githubusercontent.com/47416964/167141294-3fd220e5-f535-4e0a-98ee-ed013e360309.png)
9. Add your **Company Name** and **Non Production key** into the license panel precisely as they are in the license email you received from Kofax.
10. Download and install **Design Studio** from the download link in your license email from Kofax.
11. Start **Design Studio** and connect to Management Console at http://localhost:83  with **admin/admin**.  


This is just a Quick Start guide.
* Robot Logging and Databases are not configured. You will not be able to use the "Store in Database" step in robots, until you configure an external SQL Database.
* Default user admin/admin are used. This is not recommended practice for user management.
* There is no secrecy on passwords.
* https is not configured.
* Kapplets 11.3 are not available yet for Docker. If you need Kapplets on Docker you will have to use Kapplets 1.2.


## Quick Start Guide to installing Kofax RPA on Docker on Linux
```bash
sudo apt update
sudo apt install docker
sudo apt install curl
mkdir rpa
cd rpa
curl -JLO https://raw.githubusercontent.com/KofaxRPA/Docker/master/docker-compose.yml
docker compose -p RPA up
```
open http://localhost:83

