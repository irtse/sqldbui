FROM instrumentisto/flutter:3.19.6-androidsdk34-r0 as builder

WORKDIR /app
 
COPY . .

RUN flutter pub get
 
RUN flutter build web --release --build-number ${CI_JOB_ID:-1}

FROM scratch
 
WORKDIR /app

COPY --from=builder /app/build/web /app/web