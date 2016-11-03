bind-lib-install:
  pkg.installed:
    - names:
      - gcc
      - gcc-c++
      - kernel-devel
      - ncurses-devel
      - bison
      - cmake
      - openssl
      - openssl-devel

bind-tar-manage:
  file.managed:
    - name: /opt/bind-9.8.0-P1.tar.gz
    - source: salt://bind/file/bind-9.8.0-P1.tar.gz
    - user: root
    - group: root
  cmd.run:
    - name:  cd /opt && tar -zxf bind-9.8.0-P1.tar.gz
    - require:
      - pkg: bind-lib-install
    - unless: test -e /opt/bind-9.8.0-P1


