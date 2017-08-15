#  목적

지난번 [mcchae/docker-xfce](https://github.com/mcchae/docker-xfce) 에서 만든 것 처럼 alpine linux에 xfce 윈도우 환경을 갖춘 것에 다음과 같은 추가 작업을 진행해 보았습니다.

## 작업 내용

* pyenv : `/home/toor/.pyenv`에 pyenv을 설치해 놓았습니다. 해당 명령의 설명은 아래에 따로 기술하겠습니다.
* openjdk8 : alpine용 openjdk 버전 8을 설치하였습니다.
* xfce-termninal : 기본 터미널에 uim-byeoru 한글 입력기를 활성화 시켜 놓았습니다. (한영 전환은 Shift+Space 입니다)
* firefox : 기본 웹 브라우저로 파이어폭스를 설치하였습니다.
* pyCharm : Community Edition 2017.2 버전의 pyCharm IDE를 설치하였습니다.


## 사용법

### docker 이용

```bash
# 내 데스크탑 이름
MYDT=rdp
# docker host에서 사용할 RDP 포트
HP_RDP=33899
# docker host에서 사용할 noVNC 포트
HP_NOVNC=60811
docker container run -it \
	--name $MYDT \
	--hostname $MYDT \
	-p $HP_RDP:3389 \
	-p $HP_NOVNC:6081 \
	-v /dhv/xfce/toor:/home/toor \
	mcchae/xfce-pyenv
```

> `-it` 대신 `-d` 옵션을 이용하면 백그라운드 서비스로 실행됩니다.

### docker compose 이용

`~/mydt.yml` 이라는 이름으로 다음의 내용을 저장합니다.

``` yaml
version: '2'
services:
  mydt:
    image: "mcchae/xfce-pyenv"
    hostname: "mydt"
    environment:
      VNC_GEOMETRY: "1920x1080"
    ports:
     - "33899:3389"
     - "60811:6081"
    volumes:
     - ${HOME}/dhv/toor:/home/toor
     - ${HOME}/work:/home/toor/work
```

> * `VNC_GEOMETRY` 환경변수는 해상도를 지정합니다. xrdp 또는 noVNC 모두 적용됩니다. (위의 예에서는 1440x900 해상도로 지정하였습니다)
> * `3389` 포트는 외부로 노출될 원격데스크탑 포트입니다. (위의 예에서는 33899 포트로 접근 가능합니다)
> * `6081` 포트는 외부로 노출될 noVNC 포트입니다. (위의 예에서는 60811 포트로 접근 가능합니다)
> * docker를 돌리는 호스트에 `$HOME/dhv`라는 폴더가 있고 이 폴더에 있는 `toor` 디렉터리가 docker 컨테이너의 `/home/toor` 디렉터리로 볼륨 마운트되어 toor 홈 폴더는 영속성을 갖습니다
> * `$HOME/work` 라는 폴더에 모든 프로젝트가 있고 작업을 하는데 이것이 컨테이너의 `/home/toor/work`로 볼륨 마운트되어 프로젝트 작업을 합니다

그 다음, 다음과 같이 실행합니다.

```sh
$ docker-compose -f ~/mydt.yml up
```

> * `-d` 옵션을 이용하면 백그라운드 서비스로 실행됩니다.
> * `docker-compose -f ~/mydt.yml logs` 명령으로 컨테이너의 로그를 확인합니다. (특별히 -d 로 up 하였을 경우)
> * `docker-compose -f ~/mydt.yml down` 명령으로 컨테이너를 내립니다.

## 기타 설명

### pyenv
...

### conda

[conda](https://conda.io/docs/intro.html)는 Python 뿐만 아니라 R, Java, JavaScript, C/C++, FORTRAN 등의 언어에 대한 패키지 관리자라 할 수 있습니다. 파이썬과 같은 경우 이미 `pip` 패키지 관리자로 설치를 하고 `virtualenv` 명령으로 특정 인터프리터 환경을 갖추어 사용하는데 conda는 이런 두 가지 기능을 모두 가지고 있다고 보면 됩니다. ([해당 블로그](http://mcchae.egloos.com/11267105) 참조)

다음은 conda를 이용하여 toor 환경에서 관리하는 방법을 설명하겠습니다.

#### info

```sh
$ conda info
Current conda install:

               platform : linux-64
          conda version : 4.3.14
       conda is private : False
      conda-env version : 4.3.14
    conda-build version : not installed
         python version : 3.6.0.final.0
       requests version : 2.12.4
       root environment : /opt/conda  (read only)
    default environment : /opt/conda
       envs directories : /opt/conda/envs
                          /home/toor/.conda/envs
          package cache : /opt/conda/pkgs
                          /home/toor/.conda/pkgs
           channel URLs : https://repo.continuum.io/pkgs/free/linux-64
                          https://repo.continuum.io/pkgs/free/noarch
                          https://repo.continuum.io/pkgs/r/linux-64
                          https://repo.continuum.io/pkgs/r/noarch
                          https://repo.continuum.io/pkgs/pro/linux-64
                          https://repo.continuum.io/pkgs/pro/noarch
            config file : None
           offline mode : False
             user-agent : conda/4.3.14 requests/2.12.4 CPython/3.6.0 Linux/4.9.36-moby / glibc/2.25
                UID:GID : 1000:1000
```

위에서 envs를 확인해 보면 현재 홈(`/home/toor`) 안에 `.conda/envs` 를 같이 참조함을 알 수 있습니다.

따라서,

```sh
$ mkdir -p /home/toor/.conda/pkgs
```
라고 처음에 한번 해당 폴더를 생성해 줍니다.

#### create

다음과 같이 py36 이라는 환경을 만들어봅니다.

```sh
$ conda create -p /home/toor/.conda/envs/py36 python=3.6
```

#### info env
현재 설치된 환경을 알아봅니다.

```sh
$ conda info -e
# conda environments:
#
py36                     /home/toor/.conda/envs/py36
root                  *  /opt/conda
```
위에 나온 환경 (py36, root)을 바꿔 가면서 활성화시킬 수 있습니다.

#### activate
여러 환경 중에서 필요한 환경을 활성화 시킵니다.

```sh
$ . activate py36
(py36) $
```

#### list
현재 환경에서 설치된 패키지 목록을 살펴봅니다.

```sh
(py36) $ conda list
$ conda list
# packages in environment at /home/toor/.conda/envs/py36:
#
openssl                   1.0.2l                        0  
pip                       9.0.1                    py36_1  
python                    3.6.2                         0  
readline                  6.2                           2  
setuptools                27.2.0                   py36_0  
sqlite                    3.13.0                        0  
tk                        8.5.18                        0  
wheel                     0.29.0                   py36_0  
xz                        5.2.2                         1  
zlib                      1.2.8                         3  
```

#### search
해당 환경에서 필요한 패키지를 검색합니다.

```sh
(py36) $ conda search jupyter
Fetching package metadata .........
jupyter                      1.0.0                    py27_0  defaults        
                             1.0.0                    py34_0
...
```

#### install
특정 패키지를 설치합니다. (예는 jupyter 설치)

```sh
(py36) $ conda install jupyter
```

#### remove
특정 패키지를 삭제합니다. (예는 jupyter 삭제)

```sh
(py36) $ conda remove jupyter
```

#### deactivate
현재 선택한 환경을 해지하고 root 로 돌아갑니다.

```sh
(py36) $ . deactivate
$
```

#### remove all
특정 환경을 모두 제거합니다. (py36 이라는 환경 삭제)

```sh
$ conda remove -n py36 --all
```

# 결론

파이썬 개발 환경은 이것으로 거의 시작과 끝을 볼 수 있지 않을까 싶네요.

어느 분께는 도움이 되셨기를...

