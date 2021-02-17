FROM --platform=$BUILDPLATFORM golang:latest AS support

COPY . /opt/build

RUN apt update -y \
    && apt install build-essential python3-pip curl software-properties-common sed -y \
    && (curl -sL https://deb.nodesource.com/setup_14.x | bash -) \
    && apt install nodejs \
    && (cd /opt/build; make configuration npm email version typescript bundle-css swagger noembed copy GOESBUILD=on) \
    && sed -i 's#id="password_resets-watch_directory" placeholder="/config/jellyfin"#id="password_resets-watch_directory" value="/jf" disabled#g' /opt/build/build/data/html/setup.html


FROM --platform=$BUILDPLATFORM golang:latest AS build
ARG TARGETARCH
ENV GOARCH=$TARGETARCH

COPY --from=support /opt/build /opt/build

RUN (cd /opt/build; make compile)

FROM golang:latest

COPY --from=build /opt/build/build /opt/jfa-go

EXPOSE 8056

CMD [ "/opt/jfa-go/jfa-go", "-data", "/data" ]


