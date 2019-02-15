FROM alpine:3.8

MAINTAINER Mingda Jin <mjin@zymoresearch.com>

ENV VERSION 0.3.0

RUN apk --no-cache add --virtual deps \
      alpine-sdk \
      zlib-dev \
 && wget https://github.com/dpryan79/MethylDackel/archive/$VERSION.tar.gz \
 && tar xzvf $VERSION.tar.gz \
 && make -C MethylDackel-$VERSION \
 && make install -C MethylDackel-$VERSION \
 && rm $VERSION.tar.gz \
 && rm -r MethylDackel-$VERSION \
 && apk --no-cache del deps

WORKDIR /tmp

ENTRYPOINT ["MethylDackel"]
