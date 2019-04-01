FROM node:11.12
RUN mkdir /app
RUN mkdir /ignore
WORKDIR /app
RUN npm install -g elm --unsafe-perm