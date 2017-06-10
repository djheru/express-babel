FROM alpine:3.5

# install tini
RUN apk add --no-cache nodejs-current
RUN npm install --global yarn

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Build time argument to set NODE_ENV ('production'' by default)
ARG NODE_ENV
ENV NODE_ENV ${NODE_ENV:-production}

# Location of the app in the container
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy files and install dependencies
COPY . /usr/src/app
RUN yarn config set cache-folder /tmp && \
  rm -rf ./node_modules && \
  yarn global add pm2 && \
  yarn install && \
  yarn run build && \
  yarn cache clean && \
  rm -rf /tmp/*

EXPOSE 8080

CMD [ "pm2-docker", "dist/index.js" ]

# add VCS labels for code sync and nice reports
ARG VCS_REF="local"
LABEL org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/djheru/express-babel.git"

