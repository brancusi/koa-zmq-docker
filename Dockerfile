FROM iojs:onbuild

RUN apt-get update && apt-get install -y \
  libtool \
  autoconf \
  automake \
  make \
  g++ \
  uuid-dev \
  wget \
  openssh-server 

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

WORKDIR /tmp

RUN wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz && tar -xvf libsodium-1.0.3.tar.gz && cd libsodium-1.0.3 && ./configure && make install

RUN wget http://download.zeromq.org/zeromq-4.1.1.tar.gz && tar -xvf zeromq-4.1.1.tar.gz && cd zeromq-* && ./configure && make install && ldconfig && cd .. && rm -rf zeromq*

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]