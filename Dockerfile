# Build Stage
#
# OS : buster-slim
#
# node: 14.16.0
#
# yarn: 1.22.5

FROM node:14.16.0-buster-slim as yarn-build
LABEL maintainer="Soumik Mukherjee <me@soumikmukherjee.dev>"
# ARG CICD_USER_PAT
WORKDIR /app
COPY --chown=node:node package.json ./
COPY --chown=node:node yarn.lock ./
COPY --chown=node:node src ./src/
COPY --chown=node:node static ./static/
# COPY --chown=node:node .npmrc .
# First echo to always insert a newline
# RUN echo
# RUN echo //npm.pkg.github.com/:_authToken=${CICD_USER_PAT} >> .npmrc
# RUN echo //npm.pkg.github.com/unifo/:_authToken=${CICD_USER_PAT} >> .npmrc
# RUN echo //npm.pkg.github.com/download/@unifo/:_authToken=${CICD_USER_PAT} >> .npmrc

RUN yarn

COPY --chown=node:node .env.production /app/

RUN yarn build

# Production Stage
#
# OS : buster-slim
#
# NGINX: mainline is 1.19.8 as of 28th March, 2021

FROM nginx:mainline as image-build
COPY ./.nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=yarn-build /app/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
