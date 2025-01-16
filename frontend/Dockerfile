FROM node:22.13.0-slim

WORKDIR /client

COPY package.json /client/package.json
COPY yarn.lock /client/yarn.lock

RUN apt update && yarn install

COPY . /client

EXPOSE 5173
CMD ["yarn", "dev"]