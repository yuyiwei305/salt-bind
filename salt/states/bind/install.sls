include: 
  - bind.init

if-bind-with-mysql:
  cmd.run:
    - name: ln -s /usr/local/mysql/lib/libperconaserverclient.so.18.1.0 /usr/lib64/libmysqlclient.so * && touch /tmp/ln-mysql-lib.lock
    - unless: test -r /tmp/ln-mysql-lib.lock
    - require: 
      - cmd: bind-tar-manage

bind-all-install:
  cmd.run:
    - name: cd /opt/bind-9.8.0-P1 &&  ./configure --with-dlz-mysql=/usr/local/mysql --enable-threads --disable-openssl-version-check  --with-libtool  --enable-largefile  --prefix=/usr/local/bind  && make && make install  && touch /tmp/bind-install.lock
    - unless: test -e /tmp/bind-install.lock
    - require:
      - cmd: if-bind-with-mysql

bind-named-conf:
  file.recurse:
    - name: /usr/local/bind/etc
    - source: salt://bind/file/etc
    - user: root
    - group: root
    - template: jinja
    - defaults:
      MYSQL_SERVER: {{ pillar['bind']['MYSQL_SERVER'] }}
      MYSQL_DB_NAME: {{ pillar['bind']['MYSQL_DB_NAME'] }}
      MYSQL_DB_USER: {{ pillar['bind']['MYSQL_DB_USER'] }}
      MYSQL_DB_PASS: {{ pillar['bind']['MYSQL_DB_PASS'] }}
    - require: 
      - cmd:  bind-all-install


bind-conf-make:
  cmd.run:
    - name: cd /usr/local/bind && sbin/rndc-confgen > etc/rndc.conf && cd etc && tail -10 rndc.conf | head -9 | sed 's/#\ //g' > named.conf && cat name.temple >> named.conf
    - unless: test -e /usr/local/bind/etc/named.conf
    - require: 
      - file: bind-named-conf

bind-system-make:
  file.managed:
    - name: /etc/init.d/dns
    - source: salt://bind/file/dns
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: bind-conf-make

