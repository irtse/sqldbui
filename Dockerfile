FROM ghcr.io/cirruslabs/flutter as builder
 
WORKDIR /app
 
COPY . .

RUN flutter pub upgrade

RUN flutter pub get
 
RUN flutter build web --release --build-number ${CI_JOB_ID:-1}

FROM scratch
 
WORKDIR /app

COPY --from=builder /app/build/web /app/web