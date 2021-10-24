FROM ubuntu:focal


USER root

ENV DEBIAN_FRONTEND=noninteractive


WORKDIR /server-context


RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    git-lfs \
    python \
    python-openssl \
    unzip \
    wget \
    zip \
    adb \
    openjdk-8-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

ENV GODOT_VERSION "3.3.4"

RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip


ADD getbutler.sh /opt/butler/getbutler.sh
RUN bash /opt/butler/getbutler.sh
RUN /opt/butler/bin/butler -V

ENV PATH="/opt/butler/bin:${PATH}"

# Adding android keystore and settings
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
    && mv debug.keystore /root/debug.keystore
RUN godot -e -q


RUN wget https://downloads.tuxfamily.org/godotengine/3.3.4/Godot_v3.3.4-stable_linux_server.64.zip && \
    unzip Godot_v3.3.4-stable_linux_server.64.zip && \
    mv ./Godot_v3.3.4-stable_linux_server.64 /opt/godot-server

ADD ./rsr-srv/server-test.pck .
ADD ./rsr-srv/Godot-engine .
ADD ./rsr-clt/client.x86_64 .
ADD ./rsr-clt/client.pck .
ADD ./rsr-clt/. .

EXPOSE 4321

CMD [ "godot", "Godot-engine", "--main-pack", "server-test.pck" ]



