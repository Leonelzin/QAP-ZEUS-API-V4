FROM jenkins/jenkins:lts

# Changing user to be able to install some dependencies
USER root

# Add jenkins puglin inside of container
COPY ./config/jenkins-plugins.txt $JENKINS_HOME/jenkins-plugins.txt

# Add our jenkins groovy script to image
# TODO: Remaing create a job to be full configured
# COPY ./config/init.groovy.d/jenkins-docker-init.groovy $JENKINS_HOME/init.groovy.d/jenkins-docker-init.groovy

# Run install-plugins to skip setup plugins part
RUN /usr/local/bin/install-plugins.sh < $JENKINS_HOME/jenkins-plugins.txt

# Changing back to jenking user - GOOD PRATICE
USER jenkins

# Java environment option to instruct Jenkins to skip Setup Wizard during first startup
# ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

EXPOSE 8080 50000
