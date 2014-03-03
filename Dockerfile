FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev

#Erlang
RUN wget --no-check-certificate https://packages.erlang-solutions.com/erlang/esl-erlang-src/otp_src_R16B03-1.tar.gz && \
    tar xvf otp*tar.gz && \
    rm otp*tar.gz
RUN cd otp_src* && \
    ./configure && \
    make && \
    make install
RUN rm -rf otp_src*
RUN echo 'export PATH=/usr/local/lib/erlang/lib/erl_interface-3.7.15/bin:$PATH' >> /root/.bashrc

#Configuration
ADD . /docker
RUN ln -s /docker/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf

EXPOSE 22
