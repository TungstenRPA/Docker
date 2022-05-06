# Kofax RPA and Docker.
Kofax RPA images are now published to [Docker Hub](https://hub.docker.com/u/kofax).  
Kofax RPA 11.3.0.1 and Kofax RPA 11.3.0.1 are available. Docker Kapplets does not work due to a log-in bug.  
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
8. Open [Management Console](https://localhost:83) in your Browser  and login with **admin/admin**.  
![image](https://user-images.githubusercontent.com/47416964/167141294-3fd220e5-f535-4e0a-98ee-ed013e360309.png)
9. Add your **Company Name** and **Non Production key** into the license panel precisely as they are in the license email you received from Kofax.

