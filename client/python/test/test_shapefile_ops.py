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
    def test_simple_point_in_polygon(self):
        response = Location(34.05, -118.25).surrounding_polygons('us_state_2014').run()
        self.assertEquals(response, {'result': [{'shapefile_name': 'us_state_2014',
                                                 'name': 'California',
                                                 'id': '06'}]})

if __name__ == '__main__':
    unittest.main()
