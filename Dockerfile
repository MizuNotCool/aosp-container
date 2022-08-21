# Originally from: https://android-review.googlesource.com/c/platform/build/+/1161367
FROM debian:11
#ARG userid=1000
#ARG groupid=1000
#ARG username=build
# ARG http_proxy

# Using separate RUNs here allows Docker to cache each update


RUN DEBIAN_FRONTEND="noninteractive" apt-get update

# Make sure the base image is up to date

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-utils


RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y

# Install apt-utils to make apt run more smoothly

# Install the packages needed for the build
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git-core gnupg flex bison build-essential \
	zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
	x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip \
	fontconfig libncurses5 procps rsync libssl-dev mosh openssh-server

# Disable some gpg options which can cause problems in IPv4 only environments
# RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN mkdir /var/run/sshd

RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# Download and verify repo
#RUN gpg --keyserver keys.openpgp.org --recv-key 8BB9AD793E8E6153AF0F9A4416530D5E920F5C65
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo
# RUN curl https://storage.googleapis.com/git-repo-downloads/repo.asc | gpg --verify - /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Create the home directory for the build user
# RUN groupadd -g $groupid $username \
# && useradd -m -s /bin/bash -u $userid -g $groupid $username

# RUN groupadd sshgroup && usermod -a -G sshgroup $username

#COPY gitconfig /home/$username/.gitconfig
#RUN chown $userid:$groupid /home/$username/.gitconfig

# Create a directory which we can use to build the AOSP
#RUN mkdir /home/$username/aosp && chown $userid:$groupid /home/$username/aosp && chmod ug+s /home/$username/aosp
RUN mkdir /root/aosp
RUN echo 'echo "PUT ALL WORK ON aosp FOLDER EVERYTHING OUTSIDE WILL BE DELETED"'  > /etc/profile.d/welcome.sh
EXPOSE 1111
CMD ["/usr/sbin/sshd", "-D"]