# Kofax RPA and Docker.
Kofax RPA 11.3 & 11.4 images are now published to [Docker Hub](https://hub.docker.com/u/kofax).  
* Install [RPA on Docker on Linux](#quick-start-guide-to-installing-kofax-rpa-on-docker-on-linux)
* Install [RPA on Docker on Synology NAS](Synology%20NAS)
* 11.4 now supports 
   * Kapplets
   * Synchronizer (RSA key not quite working yet 3 Feb 2023)
   * 3 databases: MC database, log database, robot data database.
## Quickstart Guide to installing Kofax RPA on Windows from Docker Hub 
_WARNING: Do not install Docker if your laptop is running VMWare or other Virtualization Software._  
_WARNING: Make sure that your laptop supports "Hardware assisted virtualization and data execution protection" in the BIOS and that it is **enabled**._ 
### Install Docker on your machine. 
1. Upgrade your Windows installation to the latest version, if you are using Windows 10. This will make the installation of Docker and Windows Subsystem for Linux (WSL2) easier.
2. Install **Windows Subsystem for Linux** by typing **wsl --install -d Ubuntu** at the command line. You may need to reboot afterwards. [Microsoft's Guide](https://docs.microsoft.com/en-us/windows/wsl/install).  
*You need no understanding of Linux or Ubuntu to work with Kofax RPA on Docker on Windows.*   
3. Enter a username and password for Ubuntu. (You won't need them). Close the Ubuntu window.
4.  Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/).
   - Select **Use WSL 2 instead of Hyper-V (recommended)**.
### Download Docker files from GitHub
1. Get a [free Kofax RPA license](https://www.kofax.com/products/rpa/rpa-free-trial). You will have your license within 2 minutes.  
6. Download [docker-compose.yml](docker-compose.yml) from GitHub.  Click **Raw** and then Save the file.  
![image](https://user-images.githubusercontent.com/47416964/167140029-442922d9-fa48-447f-8094-d866c4eb5fff.png)  
*If you have [curl.exe](https://curl.se/download.html) installed, you can download with*
```
curl.exe -JLO https://raw.githubusercontent.com/KofaxRPA/Docker/master/docker-compose.yml
```
4. Create a folder on your computer and copy **docker-compose.yml** into it.  
![image](https://user-images.githubusercontent.com/47416964/167139416-fecbbed6-799b-43a7-a797-6cac9359a4ac.png)
5. Open Windows **Command Prompt** and change to your directory.  
![image](https://user-images.githubusercontent.com/47416964/167145058-2fe71f61-b141-4c92-a575-2b3d8dd0f10d.png)
1. Generate a secure shell private and public key for connecting your Synchronizer with a Git repository. Type **ssh-keygen** and press ENTER. *The private key will be given to the Synchronizer and later you can give the public key to GitHub to authorize the Synchronizer to upload robots to GitHub.*
### Download Kofax RPA from DockerHub and start it
1. Type  **docker compose -p kofaxrpa up**  
*-p sets the project name. Since Docker 2.5 a project name **must** be lowercase.*  
*This will download PostgreSQL database, KofaxRPA Management Console and Kofax RPA Roboserver from [Docker Hub](https://hub.docker.com/u/kofax) and then start all three running.*
8. Wait until Roboserver has started. *You will see further error messages from Management Console about a missing license. We will add that later.*   
![image](https://user-images.githubusercontent.com/47416964/167142680-fe3b0bb5-3010-49d8-97d0-a7d99e0360fa.png)
### Configure Management Console
1. Open [Management Console](http://localhost:83) at http://localhost:83 and login with **admin/admin**.  
![image](https://user-images.githubusercontent.com/47416964/167141294-3fd220e5-f535-4e0a-98ee-ed013e360309.png)
1. Add your **Company Name** and **Non Production key** into the license panel precisely as they are in the license email you received from Kofax.
### Configure Kapplets
1. Open **Admin/OAuth server/Kapplets** in Management Console.
1. Click the eye icon and copy the Client secret.  
![image](https://user-images.githubusercontent.com/47416964/215109396-5b756d85-dd74-4e5c-88b8-62eecb6ebe21.png)
1. Open Kapplets at http://localhost:84.
### Install Design Studio
1. Download and install **Design Studio** from the download link in your license email from Kofax.
1. Start **Design Studio** and connect to Management Console at http://localhost:83  with user **admin/admin**.  


This is just a Quick Start guide.
* Robot Logging and Databases are not configured. You will not be able to use the "Store in Database" step in robots, until you configure an external SQL Database.
* Default user admin/admin are used. This is not recommended practice for user management.
* There is no secrecy on passwords.
* https is not configured.

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
Open Management Console at http://localhost:83 and Kapplets at http://localhost:84

