#  :white_square_button:  Ikon  :black_square_button:
Identicon generator for Intersystems Caché. Good to use in Mojo applications.

## Parameters
1. Name that's will be converted;
2. Directory where the file will be generated;
3. Size of the image in pixels (Default = 250);
4. Amount of background red (Default = 255);
5. Amount of background green (Default = 255);
6. Amount of background blue (Default = 255).

## Example
```COS
Do ##class(Ikon.Identicon).%New("test","C:\Identicons\",250,255,255,155)
```
Result of example above:

![Result](https://github.com/AndreiLN/Ikon/blob/master/test.jpg)


## DOCKER Support
### Prerequisites   
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.    
### Installation    
Clone/git pull the repo into any local directory
```
$ git clone https://github.com/AndreiLN/Ikon.git  
```
Open the terminal in this directory and run:
```
$ docker-compose build
```
Run IRIS container with your project:
```
$ docker-compose up -d
```
Test from docker console
```
$ docker-compose exec iris1 iris session iris
USER>
```
Do ##class(Ikon.Identicon).%New("dockerdemo","/home/irisowner/dev/demo/",250,105,255,155)
```
```
or using **WebTerminal**
```
http://localhost:42773/terminal/
```
## Documentation and Discussion
See the [Article on InterSystems Developer Community](https://community.intersystems.com/post/identicon-generator-cach%C3%A9)

