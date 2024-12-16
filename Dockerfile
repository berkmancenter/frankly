# Use the official Python image.
# https://hub.docker.com/_/python
FROM python:3.7

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Install manually all the missing libraries
RUN apt-get update
RUN apt-get install -y gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libnss3 lsb-release xdg-utils
RUN apt-get install -y libappindicator1; apt-get -fy install

# Install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

# Install Python dependencies.
COPY py/scripts/cloud-run-scale-test/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# Copied from here: https://gist.github.com/varyonic/dea40abcf3dd891d204ef235c6e8dd79#gistcomment-3906510
RUN apt-get update && \
    apt-get install -y gnupg wget curl unzip --no-install-recommends && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    apt-get update -y && \
    apt-get install -y google-chrome-stable && \
    CHROMEVER=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") && \
    DRIVERVER=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROMEVER") && \
    wget -q --continue -P /chromedriver "http://chromedriver.storage.googleapis.com/$DRIVERVER/chromedriver_linux64.zip" && \
    unzip /chromedriver/chromedriver* -d /chromedriver

RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/flutter/bin"
WORKDIR /flutter
RUN git checkout 2.11.0-0.1.pre
RUN flutter doctor
WORKDIR ..

RUN git clone https://github.com/JuntoChat/flutter.git custom-flutter
RUN /custom-flutter/bin/flutter update-packages

ENV JUNTO_HOME /junto
WORKDIR $JUNTO_HOME
COPY client/. .

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR ../$APP_HOME
COPY py/scripts/cloud-run-scale-test/. .

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD exec gunicorn --bind :$PORT --workers 2 --threads 8 --preload --timeout 0 --log-level debug main:app