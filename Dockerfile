#
# Docker file for ChRIS store ui production server
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/chris_store_ui .
#
# In the case of a proxy (located at say 10.41.13.4:3128), do:
#
#    export PROXY="http://10.41.13.4:3128"
#    docker build --build-arg http_proxy=${PROXY} --build-arg UID=$UID -t local/chris_store_ui .
#
# To run the server up, do:
#
#   docker run --name chris_store_ui -p <port>:3000 -d local/chris_store_ui
#
# To run an interactive shell inside this container, do:
#
#   docker exec -it chris_store_ui sh
#

FROM node:12-alpine as builder
MAINTAINER fnndsc "dev@babymri.org"

WORKDIR /app/

COPY . .

# Build the app for production
RUN yarn install && yarn build


FROM node:12-alpine
# Pass a UID on build command line (see above) to set internal UID
ARG UID=1001
ENV UID=$UID  VERSION="0.1"

# Install server
RUN yarn global add serve --network-timeout 100000

RUN adduser -u $UID -D localuser  \
  && su - localuser -c "mkdir app"

WORKDIR /home/localuser/app/

COPY --from=builder --chown=localuser /app/build .

# Start as user localuser
USER localuser

EXPOSE 3000

# serve the production build
CMD serve --single -l 3000 .
