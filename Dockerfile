# FROM klakegg/hugo:ubuntu
# COPY . /src
# RUN ["chmod", "a+x", "/src/runthis"]
# ENTRYPOINT [ "/src/runthis" ]

FROM golang

COPY . /src

RUN wget http://github.com/gohugoio/hugo/releases/download/v0.80.0/hugo_0.80.0_Linux-64bit.deb && \
    dpkg -i hugo_0.80.0_Linux-64bit.deb && rm hugo_0.80.0_Linux-64bit.deb

RUN ["chmod", "a+x", "/src/runthis"]

ENTRYPOINT ["/src/runthis"]