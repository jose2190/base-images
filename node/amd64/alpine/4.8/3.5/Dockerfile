# AUTOGENERATED FILE
FROM resin/amd64-alpine-buildpack-deps:3.5

ENV NODE_VERSION 4.8.6

# Install dependencies
RUN apk add --no-cache libgcc libstdc++ libuv libcrypto1.0 libssl1.0

RUN curl -SLO "http://resin-packages.s3.amazonaws.com/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-alpine-amd64.tar.gz" \
	&& echo "0f26c9f40536a8db3cd08c22755cdf78b3097ecee9291b99f7aa99400fa08b60  node-v4.8.6-linux-alpine-amd64.tar.gz" | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-alpine-amd64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-alpine-amd64.tar.gz" \
	&& npm config set unsafe-perm true -g --unsafe-perm \
	&& rm -rf /tmp/*

CMD ["echo","'No CMD command was set in Dockerfile! Details about CMD command could be found in Dockerfile Guide section in our Docs. Here's the link: http://docs.resin.io/deployment/dockerfile"]
