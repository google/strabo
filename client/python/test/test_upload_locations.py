#
# Copyright 2015 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

from strabo.connection import StraboConnection
from strabo.location import Location, LocationSet

import unittest
import os

TEST_DIR = os.path.dirname(os.path.realpath(__file__))

class UploadTest(unittest.TestCase):
    def test_simple_upload(self):
        response = Location(2, 20).nearest_neighbors(self.set1, 1).run()
        self.assertEquals(response, {'result': [{'lat': 0.11, 'lon': 10.22}]})

    def test_location_set_map(self):
        response = self.set1.map(lambda x: x.nearest_neighbor(self.set2)).run()
        self.assertTrue('result' in response)
        self.assertItemsEqual(response['result'], [{'lat': 31.0, 'lon': -120.01},
                                                   {'lat': -2.0, 'lon': 8.0}])

    def setUp(self):
        self.set1 = LocationSet(filename =
                os.path.join(TEST_DIR, 'testdata', 'upload_locations_test.csv'),
                                id_column = 'id',
                                lat_column = 'lat',
                                lon_column = 'lon')
        self.set2 = LocationSet(filename =
                os.path.join(TEST_DIR, 'testdata', 'second_test_location_set.csv'),
                                id_column = 'point_id',
                                lat_column = 'latitude',
                                lon_column = 'longitude')

    def tearDown(self):
        self.assertEquals(self.set1.clear().run(), {'result': {"num_rows_affected": 2}})
        self.assertEquals(self.set2.clear().run(), {'result': {"num_rows_affected": 3}})

if __name__ == '__main__':
    unittest.main()
