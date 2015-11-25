{% set postgres_version = "9.4" %}
{% set postgis_version = "2.1" %}

postgres-server:
  pkg.installed:
    - names:
      - postgresql-{{ postgres_version }}
      - postgresql-contrib-{{ postgres_version }}
      - postgresql-{{ postgres_version }}-postgis-{{ postgis_version }}
      - postgis

strabo_dev:
  postgres_user.present:
    - password: password

    - require:
      - pkg: postgres-server

  postgres_database.present:
    - owner: strabo_dev
    - template: template0
    - encoding: 'UTF8'
    - lc_collate: 'en_US.utf8'
    - lc_type: 'en_US.UTF-8'

    - require:
      - postgres_user: strabo_dev

  postgres_extension.present:
    - name: postgis
    - maintenance_db: strabo_dev

strabo_test:
  postgres_user.present:
    - password: password

    - require:
      - pkg: postgres-server

  postgres_database.present:
    - owner: strabo_test
    - template: template0
    - encoding: 'UTF8'
    - lc_collate: 'en_US.utf8'
    - lc_type: 'en_US.UTF-8'

    - require:
      - postgres_user: strabo_test

  postgres_extension.present:
    - name: postgis
    - maintenance_db: strabo_test
