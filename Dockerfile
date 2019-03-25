FROM node:11.12
RUN mkdir /app
WORKDIR /app
RUN npm install -g elm --unsafe-perm