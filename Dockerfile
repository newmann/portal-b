#
#FROM nginx:1.13.5-alpine
#LABEL authors="Newemann <newmannhu@qq.com>"
#
#COPY ./_nginx/default.conf /etc/nginx/conf.d/default.conf
#COPY ./_nginx/ssl/* /etc/nginx/ssl/
#
#RUN rm -rf /usr/share/nginx/html/*
#
#COPY ./dist/* /usr/share/nginx/html/
#
#CMD [ "nginx", "-g", "daemon off;"]

# STEP 1: Build
#FROM beiyelin/front-base
FROM node:8-alpine as builder

LABEL authors="Newemann <newmannhu@qq.com>"

COPY package.json package-lock.json ./

RUN npm set progress=false && npm config set depth 0 && npm cache clean --force

RUN npm config set registry http://registry.cnpmjs.org

RUN npm i && mkdir /front-alain && cp -R ./node_modules ./front-alain

WORKDIR /front-alain

COPY . .

RUN npm run build

# STEP 2: Setup
FROM nginx:1.13.5-alpine

COPY --from=builder /front-alain/_nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /front-alain/_nginx/ssl/* /etc/nginx/ssl/

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /front-alain/dist /usr/share/nginx/html

CMD [ "nginx", "-g", "daemon off;"]
