
    Start Git Bash.
    Configure Git to disable SSL, if necessary.

    git config --global http.sslVerify false

    Configure the proxy server, if necessary.
    git config --global http.proxy http://www.testproxyserver.com:80/

 
    Navigate to the directory where you want to clone the Git cloud repository.
    Clone the Git cloud repository using the desired protocol.
    git clone https://github.com/lephotographelibre/LinuxPhotoWorkflow.git

    Copy the application files to the cloned repository directory.

    Use the git add command to add new files to the cloned repository.
    git add workflow.sh 

    Commit all files to the cloned Git repository.
    git commit -a -m "v1.0.3- Normalise et renomme fichiers source .jpg en .JPG"

    Push the transaction to the Git cloud repository.
    git push origin master
    Username for 'https://github.com': lephotographelibre@yahoo.com
    Password for 'https://lephotographelibre@yahoo.com@github.com': *********

    Enter exit to close the Git Bash prompt.
