# FROM klakegg/hugo:ubuntu
# COPY . /src
# RUN ["chmod", "a+x", "/src/runthis"]
# ENTRYPOINT [ "/src/runthis" ]

FROM golang

COPY . /src

RUN wget https://github.com/gohugoio/hugo/releases/download/v0.66.0/hugo_0.66.0_Linux-64bit.deb && \
    dpkg -i hugo_0.66.0_Linux-64bit.deb && rm hugo_0.66.0_Linux-64bit.deb

RUN ["chmod", "a+x", "/src/runthis"]

ENTRYPOINT ["/src/runthis"]