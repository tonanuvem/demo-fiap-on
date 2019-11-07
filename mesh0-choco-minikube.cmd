@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco install minikube kubernetes-helm curl wget
minikube start --memory=12288 --cpus=4 --kubernetes-version=v1.14.2 --vm-driver=virtualbox
wget https://github.com/istio/istio/releases/download/1.3.0/istio-1.3.0-win.zip
7z x istio-1.3.0-win.zip
