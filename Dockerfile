#node v12.x
FROM node:erbium AS Build

WORKDIR /app

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY .babelrc .babelrc
COPY public public
COPY src src

RUN npm install
RUN npm run test

RUN npm run build

# Using nginx to run application since npm build produce static files
FROM nginx

COPY --from=Build /app/build /usr/share/nginx/html
