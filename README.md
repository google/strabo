# Strabo

Strabo is a system designed to make it easy to run fast, scalable, and potentially complex geospatial analyses over your data. It allows simple expressions like

    Location(34.05, -118.25).nearest_neighbors(
        LocationSet(filename='my_data.csv', lat_column='lat', lon_column='lon', id_column='id'), 10)
    
Under the hood, this query will be executed by uploading `my_data.csv` to a Strabo server (either remote or local), inserting all location data into a database table indexed by a k-nearest-neighbors geospatial index, executing a kNN query on this table, and finally returning the top 10 results closest to the target point.

More complex queries are also possible, for instance:

    set1 = LocationSet(filename='set1.csv', lat_column='lat', lon_column='lon', id_column='id')
    set2 = LocationSet(filename='set2.csv', lat_column='lat', lon_column='lon', id_column='id')
    set1.map(lambda point: point.nearest_neighbor(set2))
    
which will return a list of all points in `set1.csv` joined with the closest location from `set2.csv`. 

Strabo is a wrapper around [PostGIS](http://postgis.net/), a widely used and well tested set of extensions to PostgreSQL that provide spatial indices, joins, querying, and shapefile operations. It is implemented in Elixir and runs on the BEAM VM, so the server is fault tolerant and queries automatically make use of all available cores if possible. Strabo currently comes with a Python-based query language, but client libraries for other languages are planned in the future. 

Strabo is still in the very early stages of development, and is definitely not recommended for production usage.

Server Installation
-------------------

1. Install [Vagrant](http://www.vagrantup.com/downloads) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads). If you are running Ubuntu, make sure you install Vagrant directly from their website, as the version in the Ubuntu repos is out of date.
2. Clone this repo. `cd` into it and run `vagrant up`. This step will take a while.
3. Once the Vagrant box has been downloaded, installed and provisioned; type `vagrant ssh` (from within the Strabo directory).
4. At the vagrant prompt, run `run_migrations` to install dependencies and run all schema migrations.
5. Once migrations are complete, run `start_server` to start the Strabo server.
6. You can run tests with `run_tests`.

Now you can visit `localhost:4001` from your browser. If it displays a "Welcome to Phoenix" page; you are good to go!

Client Installation
-------------------

This repository includes a Python client library designed to interact with the Strabo server. To install it, `cd` into this repository and run

    virtualenv venv
    source venv/bin/activate
    cd client/python/
    python setup.py install
    
To verify that everything is working, run the tests with: 
    
    python -m unittest discover test/
    
If the tests pass, then the client library is installed correctly and the server is up and running.

Roadmap
-------

1. Support for downloading geographic shapefiles from the US Census Bureau (and other data sources), importing into Strabo, and using them in queries like `my_location.get_containing_polygon('us_counties_2014')`. This is almost complete.
2. Swap current Enum.map implementation for a parallel one that uses all available cores.
3. Allow calculation of road distance using TIGER/LINE or OSM data.
4. API to allow real-time upload of location data (for instance, from a mobile app). This is pretty much complete but needs to be cleaned up and documented.
5. Allow saving a kernel (i.e. a Strabo query with parameters) to the database, and exposing said kernel as an API endpoint. This is nearly complete on the backend (there is a kernels table, and queries with parameters are supported), but it needs to be finished and documented.

Legal notes
-----------
This is not an official Google product.
