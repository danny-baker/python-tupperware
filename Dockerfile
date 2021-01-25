# This builds a minimalist alpine container with some popular python libraries

# pull build image from docker
FROM python:3.8-alpine as build

# Initial setup for some package dependencies
RUN apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --update --no-cache python3 python3-dev libgfortran

# MATPLOTLIB
RUN apk add --update --no-cache build-base libstdc++ libpng libpng-dev freetype freetype-dev

# PANDAS & NUMPY
RUN apk add --update --no-cache build-base libpq libffi-dev musl-dev libressl-dev gcc g++ py3-virtualenv

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# build venv and install packates with pip
RUN virtualenv -p python3.8 --python=/usr/local/bin/python3.8 /venv
RUN /venv/bin/pip install --upgrade pip
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install -r /requirements.txt

# BUILD FINAL IMAGE
FROM python:3.8-alpine

# copy venv from build image
COPY --from=build /venv/ /venv

# copy all files in Dockerfile working directory into new container (for convenience)
COPY ./ /home/project
WORKDIR /home/project

#CMD ["/bin/sh", "-c", ". startup.sh"]
CMD /bin/sh
