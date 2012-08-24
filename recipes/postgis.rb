#
# Cookbook Name:: postgresql
# Recipe:: postgis
#

require_recipe "postgresql"

package "postgresql-#{node["postgresql"]["version"]}-postgis"

version = node[:postgresql][:version]
postgis_version = node[:postgresql][:postgis_version]

routines = "/usr/share/postgresql/#{version}/contrib/postgis-#{postgis_version}"

bash "creating postgis template" do 
  user "postgres"
  code [
        # Db creation
        "createdb -E UTF8 -U postgres template_postgis;",
        "createlang -d template_postgis plpgsql;",

        # Loading routines
        "psql -d template_postgis -f #{routines}/postgis.sql;",
        "psql -d template_postgis -f #{routines}/spatial_ref_sys.sql;",

        # Make editable
        "psql -d template_postgis -c \"GRANT ALL ON geometry_columns TO PUBLIC;\";",
        "psql -d template_postgis -c \"GRANT ALL ON geography_columns TO PUBLIC;\";",
        "psql -d template_postgis -c \"GRANT ALL ON spatial_ref_sys TO PUBLIC;\";",

        # Mark as template
        "psql -d postgres -c \"UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';\"",
       ].join(" ")
end
