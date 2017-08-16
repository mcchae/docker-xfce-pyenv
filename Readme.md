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
> * 윈도우인 경우에는 볼륨 마운트에서 `//c/Users/mcchae/dhv/toor:/home/toor` (사용자가 mcchae 라고 가정) 와 같은 방식으로 마운트 합니다. (윈도우 docker가 디폴트로 해당 사용자 부분을 마운트 가능하도록 해 놓았습니다)

그 다음, 다음과 같이 실행합니다.

```sh
$ docker-compose -f ~/mydt.yml up
```

> * `-d` 옵션을 이용하면 백그라운드 서비스로 실행됩니다.
> * `docker-compose -f ~/mydt.yml logs` 명령으로 컨테이너의 로그를 확인합니다. (특별히 -d 로 up 하였을 경우)
> * `docker-compose -f ~/mydt.yml down` 명령으로 컨테이너를 내립니다.

## 기타 설명

### pyenv

pyenv는 pip와 virtualenv 기능을 합한 conda와 달리 더 상의 개념을 지니고 있는 느낌입니다.

#### 설치가능한 파이썬 버전 확인

``` bash
$ pyenv install --list
Available versions:
  2.1.3
  2.2.3
  ...
  2.7.13
  3.0.1
  ...
  3.6.2
  3.7-dev
  anaconda-1.4.0
  ...
  anaconda3-4.4.0
  ironpython-dev
  ...
  jython-2.7.1b3
  micropython-dev
  miniconda-latest
  ...
  miniconda3-4.3.11
  pypy-c-jit-latest
  ...
  pypy3.5-5.8.0
  pyston-0.5.1
  pyston-0.6.0
  pyston-0.6.1
  stackless-dev
  stackless-2.7-dev
  stackless-2.7.2
  ...
  stackless-3.4.2
```

> * 기본 파이썬(CPython)의 최소 버전은 `2.1.3` 입니다
> * 기본 파이썬(CPython)의 버전2의 마지막버전은 `2.7.13` 입니다
> * 기본 파이썬(CPython)의 버전3의 마지막버전은 `3.6.2` 입니다
> * Anaconda 패키지 설치도 가능한데 마지막 버전은 `anaconda3-4.4.0` 입니다
> * C# Python 구현체인 ironpython도 `2.7.7` 까지 있습니다
> * Java Python 구현체인 jython도 `2.7.1b3` 까지 있습니다
> * 아두이노와 같은 하드웨어 보드 형식의 인터프리터인 micropython도 dev 버전이 있습니다
> * Anaconda의 최소 설치버전인 miniconda도 `miniconda3-4.3.11` 까지 있습니다. 하지만 alpine에서 현재 설치가능한 마지막 버전은 `miniconda3-4.0.5` 입니다 (musl 대신 glibc 로 패키지를 빌드해 놓았기에 발생하는 문제)
> * 파이썬 JIT 구현체인 pypy도 있습니다
> * 또다른 JIT 구현체인 pystone도 있습니다
> * [Stackless Python](https://en.wikipedia.org/wiki/Stackless_Python) 도 있습니다

#### python 설치 및 확인

```bash
$ pyenv install 3.6.2
```

위와 같이 설치하고

```bash
$ pyenv versions
  system
* 2.7.13 (set by /Users/mcchae/.pyenv/version)
  3.6.2
```

위와 같이 설치된 버전을 확인합니다.

#### 해당 버전 쉘 이용

``` bash
$ pyenv shell 2.7.13
$ python -V
Python 2.7.13
$ pyenv shell 3.6.2
$ python -V
Python 3.6.2
```

#### virtualenv 이용

> pyenv virtualenv plugin을 설치해야 합니다

##### virtualenv 생성

``` bash
$ pyenv virtualenv 2.7.13 py27
$ pyenv virtualenv 3.6.2 py36
```
위와 같이 특정 파이썬에 대한 virtualenv 환경을 만들면 됩니다.

##### 환경 목록 확인

설치된 모든 virtualenv 환경을 보려면,

``` bash
$ pyenv virtualenvs
  2.7.13/envs/py27 (created from /Users/mcchae/.pyenv/versions/2.7.13)
  3.6.2/envs/py36 (created from /Users/mcchae/.pyenv/versions/3.6.2)
  miniconda3-4.3.11 (created from /Users/mcchae/.pyenv/versions/miniconda3-4.3.11)
  py27 (created from /Users/mcchae/.pyenv/versions/2.7.13)
  py36 (created from /Users/mcchae/.pyenv/versions/3.6.2)
```

와 같이 하면 되고,
해당 환경으로 들어가거나 나오려면,

##### 환경 이동 및 나오기

``` bash
$ pyenv activate py27
...
(py27) $ pyenv deactivate
$
```

##### 환경 삭제

만약 해당 virtualenv를 삭제하려면,

``` bash
$ pyenv uninstall py36
```

이라고 하면 됩니다.

해당 인터프리터까지 삭제하려면,

``` bash
$ pyenv uninstall 3.6.2
```

라고 하면 됩니다.

##### autoenv

또 autoenv 가 설치되어 있다고 가정하면,

특정 디렉터리에 접근할 때 필요한 환경으로 가기위하여,

``` bash
$ cd work27
$ echo "pyenv activate py27" > .env
```

와 같이 지정해주면, 해당 폴더를 들어가면서 자동으로 해당 환경으로 변경됩니다.

##### 환경 확인

> 주의! 필요에 따라 홈에 .bashrc 또는 .bash_profile 에 다음과 같은 내용이 포함되어 있어야 합니다.
>
> ```
> eval "$(pyenv init -)"
> eval "$(pyenv virtualenv-init -)"
> source $HOME/.autoenv/activate.sh
> # mac에서 brew install autoenv 로 설치한 경우에는
> source /usr/local/opt/autoenv/activate.sh
> ```
> 와 같은 설정이 포함되어 실행되어야 합니다.


### conda

[conda](https://conda.io/docs/intro.html)는 Python 뿐만 아니라 R, Java, JavaScript, C/C++, FORTRAN 등의 언어에 대한 패키지 관리자라 할 수 있습니다. 파이썬과 같은 경우 이미 `pip` 패키지 관리자로 설치를 하고 `virtualenv` 명령으로 특정 인터프리터 환경을 갖추어 사용하는데 conda는 이런 두 가지 기능을 모두 가지고 있다고 보면 됩니다. ([해당 블로그](http://mcchae.egloos.com/11267105) 참조)

다음은 위의 pyenv 하에서 conda를 이용하여 toor 환경에서 관리하는 방법을 설명하겠습니다.

#### miniconda 설치

> Anaconda 대신 가벼운 Miniconda 를 기준으로 합니다

``` bash
$ pyenv install miniconda3-4.0.5
```

> 주의! 현재 버전의 alpine은 `miniconda3-4.0.5` 버전까지만 설치됩니다.

#### 해당 가상 환경 만들고 이동

``` bash
$ pyenv virtualenv miniconda3-4.0.5 conda3
$ pyenv activate conda3
```

#### info

```sh
(conda3) $ conda info
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

#### create

다음과 같이 py34 이라는 환경을 만들어봅니다. (예로 파이썬 3.4.0 을 들었습니다)

```sh
(conda3) $ conda create -n cpy36 python=3.4.0
```

#### 가상환경 조사
현재 설치된 환경을 알아봅니다.

```sh
(conda) $ pyenv virtualenvs
* conda3 (created from /home/toor/.pyenv/versions/conda3)
  miniconda3-4.0.5 (created from /home/toor/.pyenv/versions/miniconda3-4.0.5)
  miniconda3-4.0.5/envs/conda3 (created from /home/toor/.pyenv/versions/miniconda3-4.0.5/envs/conda3)
  miniconda3-4.0.5/envs/cpy34 (created from /home/toor/.pyenv/versions/miniconda3-4.0.5/envs/cpy34)
```
위에 나온 환경을 바꿔 가면서 활성화시킬 수 있습니다.

#### activate
여러 환경 중에서 필요한 환경을 활성화 시킵니다.

```sh
(conda3) $ pyenv activate miniconda3-4.0.5/envs/cpy34
(miniconda3-4.0.5/envs/cpy34) $ python -V
3.4.0
```

#### list
현재 환경에서 설치된 패키지 목록을 살펴봅니다.

```sh
(miniconda3-4.0.5/envs/cpy34) $ conda list
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
(miniconda3-4.0.5/envs/cpy34) $ conda search jupyter
Fetching package metadata .........
jupyter                      1.0.0                    py27_0  defaults        
                             1.0.0                    py34_0
...
```

#### install
특정 패키지를 설치합니다. (예는 jupyter 설치)

```sh
(miniconda3-4.0.5/envs/cpy34) $ conda install jupyter
```

#### remove
특정 패키지를 삭제합니다. (예는 jupyter 삭제)

```sh
(miniconda3-4.0.5/envs/cpy34) $ conda remove jupyter
```

#### deactivate
현재 선택한 환경을 해지하고 root 로 돌아갑니다.

```sh
(miniconda3-4.0.5/envs/cpy34) $ pyenv deactivate
$
```

#### remove all
특정 환경을 모두 제거합니다. (py36 이라는 환경 삭제)

```sh
$ pyenv uninstall miniconda3-4.0.5/envs/cpy34
```

# 결론

파이썬 개발 환경은 이것으로 거의 시작과 끝을 볼 수 있지 않을까 싶네요.

어느 분께는 도움이 되셨기를...

