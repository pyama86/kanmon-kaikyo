FROM ruby:2.6.3
ADD Gemfile      /opt/kanmon-kaikyo/Gemfile
ADD Gemfile.lock /opt/kanmon-kaikyo/Gemfile.lock

WORKDIR /opt/kanmon-kaikyo
RUN gem install bundler -N
RUN bundle install --deployment --without development,test -j4

ADD . /opt/kanmon-kaikyo

ENTRYPOINT ["bundle", "exec"]
CMD ["kanmon-kaikyo"]
