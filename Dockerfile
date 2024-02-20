# Dockerfile
FROM ruby:3.0.0

RUN apt-get update -yqq \
  && apt-get install -yqq \
    postgresql-client \
    unixodbc \
    unixodbc-dev \
    freetds-dev \
    sqsh \
    tdsodbc \
    unzip \
    libsasl2-modules-gssapi-mit \
  && apt-get -q clean \
  && rm -rf /var/lib/apt/lists

RUN curl -sL https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc/2.7.7/SimbaSparkODBC-2.7.7.1016-Debian-64bit.zip -o databricksOdbc.zip && unzip databricksOdbc.zip
RUN dpkg -i simbaspark_2.7.7.1016-2_amd64.deb
RUN export ODBCINI=/etc/odbc.ini ODBCSYSINI=/etc/odbcinst.ini SIMBASPARKINI=/opt/simba/spark/lib/64/simba.sparkodbc.ini

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .
