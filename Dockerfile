# Environemnt to install flutter and build web
FROM debian:latest AS build-env

ARG HOST=${HOST:-"http://capitalisation.irt-aese.local"}
ARG VERSION=${VERSION:-"v1.1"}

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git unzip

# define variables
ARG FLUTTER_SDK=/usr/local/flutter 
ARG FLUTTER_VERSION=3.19.6
ARG APP=/app/

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# doctor to see if all was installes ok
RUN flutter doctor -v

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY . $APP
# stup new folder as the working directory
WORKDIR $APP

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter clean
RUN flutter pub get
RUN flutter build web \
    --dart-define=APP_NAME="OPPS" \
    --dart-define=VERSION="$VERSION"  \
    --dart-define=HOST="$HOST" \
    --dart-define=BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --dart-define=BUILD_ID=$(uuidgen) \
    --release --build-number 1

# once heare the app will be compiled and ready to deploy

# use nginx to deploy
FROM nginx:1.25.2-alpine

# copy the info of the builded web app to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose and run nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]