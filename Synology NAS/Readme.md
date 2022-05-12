# Kofax RPA in Synology NAS
[Synology](https://www.synology.com) offers [Docker](https://www.docker.com) as an [add-on package](https://www.synology.com/en-global/dsm/packages/Docker).


* Download images from [Docker Hub](https://hub.docker.com/u/kofax) 
  * [postgres:10](https://hub.docker.com/layers/postgres/library/postgres/10/images/sha256-5e2c4d59cf599b1ca340713348c4af1c77f48b2b1c5a21358a94ba70ea00d167?context=explore)
  * [kofax/rpa-managementconsole:latest](https://hub.docker.com/layers/rpa-managementconsole/kofax/rpa-managementconsole/latest/images/sha256-71ed88d49e7e58cb5774f7969a11c383ea81b66cc22be6d301844d4288b21467?context=explore)
  *	[kofax/rpa-roboserver:latest](https://hub.docker.com/layers/rpa-roboserver/kofax/rpa-roboserver/latest/images/sha256-758c23e2bbf66511f0429718fa7ff0cba019f884772b59cb25600e35b1f4688d?context=explore)
* If no Docker Containers are already installed, open the configuration of any. Delete the configuration straight away. This will enable the **import settings** option.
* Import the Synology settings files for the 3 containers. 
  * [postgres.syno.json](postgres.syno.json)
  * [kofax-rpa-managementconsole.syno.json](kofax-rpa-managementconsole.syno.json)
  * [kofax-rpa-roboserver.syno.json](kofax-rpa-roboserver.syno.json)

## Detailed steps if not importing config settings
![image](https://user-images.githubusercontent.com/47416964/168106871-cc818ba2-56c3-41ac-a119-697c976f65df.png)  
![image](https://user-images.githubusercontent.com/47416964/168107023-2db31b27-c0cc-471c-8564-d4a82e2bf1a3.png)  

* Create the Docker Containers.  
![image](https://user-images.githubusercontent.com/47416964/168107140-0fa4ee89-4c79-4b78-bf27-54857b52c173.png)  
![image](https://user-images.githubusercontent.com/47416964/168107182-b9f549b2-8431-4404-b1a6-0122903d7266.png)  
![image](https://user-images.githubusercontent.com/47416964/168107198-83b103e4-e387-44ef-a0b2-2c9e91ea855b.png)  
![image](https://user-images.githubusercontent.com/47416964/168107211-7d31fc6d-7708-4bf2-b89c-fb39ab0a956c.png)  
* Add environment variables and docker links in the Advanced Settings for the containers.
![image](https://user-images.githubusercontent.com/47416964/168107349-6df79d18-033b-4a77-87dc-9fabf90de9c3.png)  
![image](https://user-images.githubusercontent.com/47416964/168107388-766b27de-1dd4-4392-ba07-2ba1de0fb749.png)  
* Configure Logging and Terminals in the Docker Container.  
![image](https://user-images.githubusercontent.com/47416964/168107477-862a4ac4-7b14-4e9d-bfa4-7816ca51ac8a.png)  
![image](https://user-images.githubusercontent.com/47416964/168107498-6aba395c-e789-4729-9686-fd2c13f18ddb.png)  
![image](https://user-images.githubusercontent.com/47416964/168107514-48739871-6edb-4873-a24f-b1dc6b158bdc.png)  

* monitoring Kofax RPA on Synology NAS  
![image](https://user-images.githubusercontent.com/47416964/168106663-1a077ceb-2b92-4b69-a725-f19390485698.png)  
