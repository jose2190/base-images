# AUTOGENERATED FILE
FROM resin/jetson-tx2-alpine-node:6.12.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD COPY package.json /usr/src/app/
ONBUILD RUN DEBIAN_FRONTEND=noninteractive JOBS=MAX npm install --unsafe-perm
ONBUILD COPY . /usr/src/app

CMD [ "npm", "start" ]
