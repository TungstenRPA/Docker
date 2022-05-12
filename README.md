# Kofax RPA and Docker.
Kofax RPA images are now published to [Docker Hub](https://hub.docker.com/u/kofax).  
Kofax RPA 11.3.0.0 and Kofax RPA 11.3.0.1 are available. Docker Kapplets currently does not work due to a log-in bug.  
[Windows](#quickstart-guide-to-installing-kofax-rpa-on-windows-from-docker-hub) : [Linux](#quick-start-guide-to-installing-kofax-rpa-on-docker-on-linux) : [Synergy NAS](Synergy%20NAS)
## Quickstart Guide to installing Kofax RPA on Windows from Docker Hub 
1. Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/).
2. Get a [free Kofax RPA license](https://www.kofax.com/products/rpa/rpa-free-trial). You will have your license within 2 minutes.  
3. Download [docker-compose.yml](docker-compose.yml) from GitHub.  Click **Raw** and then Save the file.  
![image](https://user-images.githubusercontent.com/47416964/167140029-442922d9-fa48-447f-8094-d866c4eb5fff.png)

4. Create a folder on your computer and copy **docker-compose.yml** into it.  
![image](https://user-images.githubusercontent.com/47416964/167139416-fecbbed6-799b-43a7-a797-6cac9359a4ac.png)
5. Open Windows **Command Prompt** and change to your directory.  
![image](https://user-images.githubusercontent.com/47416964/167145058-2fe71f61-b141-4c92-a575-2b3d8dd0f10d.png)
6. Install **Windows Subsystem for Linux** by typing **wsl --install**. You may need to reboot afterwards.
6. Type  **docker compose -p KofaxRPA up**
7. Wait until Roboserver has started.  
![image](https://user-images.githubusercontent.com/47416964/167142680-fe3b0bb5-3010-49d8-97d0-a7d99e0360fa.png)
8. Open [Management Console](https://localhost:83) at https://localhost:83 and login with **admin/admin**.  
![image](https://user-images.githubusercontent.com/47416964/167141294-3fd220e5-f535-4e0a-98ee-ed013e360309.png)
9. Add your **Company Name** and **Non Production key** into the license panel precisely as they are in the license email you received from Kofax.
10. Download and install **Design Studio** from the download link in your license email from Kofax.
11. Start **Design Studio** and connect to Management Console at https://localhost:83  with **admin/admin**.  


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

