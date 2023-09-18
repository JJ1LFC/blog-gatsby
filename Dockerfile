FROM node:18-alpine
RUN apk update && apk upgrade && apk add --no-cache \
  bash \
  git \
  g++ \
  make \
  python3 \
  yarn \
  && yarn global add gatsby-cli@latest \
  && gatsby options set pm yarn \
  && yarn install
EXPOSE 8000 9000

