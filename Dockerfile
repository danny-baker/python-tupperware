# This builds a minimalist alpine container with some popular python libraries

# pull build image from docker
FROM python:3.8-alpine as build

# Initial setup for some package dependencies
RUN apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --update --no-cache python3 python3-dev libgfortran

#GLOBAL
RUN apk --no-cache --update add py3-virtualenv py-pip build-base gcc g++

# NUMPY
RUN apk --no-cache add musl openblas

# PANDAS
RUN apk --no-cache add libgcc libstdc++ musl py3-dateutil py3-numpy py3-tz py3-six python3

# SCIPY
#RUN apk --no-cache add py3-scipy libgcc libgfortran libstdc++ musl openblas py3-numpy-f2py
# https://pkgs.alpinelinux.org/package/edge/community/x86/py3-scipy

# MATPLOTLIB
RUN apk --no-cache add freetype libgcc libstdc++ musl py3-cairo py3-certifi py3-cycler py3-dateutil py3-kiwisolver py3-numpy py3-parsing py3-pillow py3-tz python3-tkinter

# extras ??
RUN apk --no-cache add libpq libffi-dev musl-dev libressl-dev 

# PILLOW (needed by matplotlib)
RUN apk --no-cache add openssl freetype-dev fribidi-dev harfbuzz-dev jpeg-dev lcms2-dev openjpeg-dev tcl-dev tiff-dev tk-dev zlib-dev

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# build venv and install packages with pip
RUN virtualenv -p python3.8 --python=/usr/local/bin/python3.8 /venv
RUN /venv/bin/pip install --upgrade pip
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install -r /requirements.txt

# BUILD FINAL IMAGE
FROM python:3.8-alpine

# This shared library is needed at runtime by pandas and matplotlib
RUN apk --update add --no-cache libstdc++

# copy venv from build image
COPY --from=build /venv/ /venv

# copy all files in Dockerfile working directory into new container (for convenience)
COPY ./ /home/project
WORKDIR /home/project

#CMD ["/bin/sh", "-c", ". startup.sh"]
CMD /bin/sh

#Don't forget to start the venv from the shell in container (or packages won't work) either by: "$source /venv/bin/activate" or "$source startup.sh"
